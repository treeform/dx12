$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$examplesDir = Join-Path $repoRoot "examples"
$docsDir = Join-Path $repoRoot "docs"
$tempDir = Join-Path $env:TEMP "dx12-example-captures"

New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
New-Item -ItemType Directory -Force -Path $docsDir | Out-Null

Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class NativeMethods {
  [StructLayout(LayoutKind.Sequential)]
  public struct RECT {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
  }

  [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Unicode)]
  public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

  [DllImport("user32.dll", SetLastError=true)]
  public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);

  [DllImport("user32.dll", SetLastError=true)]
  public static extern bool SetForegroundWindow(IntPtr hWnd);

  [DllImport("user32.dll", SetLastError=true)]
  public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

Add-Type -AssemblyName System.Drawing

$examples = @(
  @{ Name = "basic_screen"; Source = "basic_screen.nim"; Title = "DirectX 12 Color Cycle" },
  @{ Name = "basic_triangle"; Source = "basic_triangle.nim"; Title = "DirectX 12 Basic Triangle" },
  @{ Name = "shader_triangle"; Source = "shader_triangle.nim"; Title = "DirectX 12 Basic Triangle" },
  @{ Name = "basic_quad"; Source = "basic_quad.nim"; Title = "DirectX 12 Textured Quad" },
  @{ Name = "basic_cube"; Source = "basic_cube.nim"; Title = "DirectX 12 Basic Cube" },
  @{ Name = "spritesheet"; Source = "spritesheet.nim"; Title = "DirectX 12 Sprite Sheet" },
  @{ Name = "viewer_obj"; Source = "viewer_obj.nim"; Title = "DirectX 12 Bunny Viewer" }
)

function Wait-ForWindow {
  param(
    [System.Diagnostics.Process]$Process,
    [string]$Title,
    [int]$TimeoutSeconds = 30
  )

  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  do {
    $Process.Refresh()
    $hwnd = $Process.MainWindowHandle
    if ($hwnd -eq 0 -and $Title) {
      $hwnd = [NativeMethods]::FindWindow($null, $Title)
    }
    if ($hwnd -ne [IntPtr]::Zero) {
      return $hwnd
    }
    if ($Process.HasExited) {
      throw "Process exited before a window became available: $Title"
    }
    Start-Sleep -Milliseconds 250
  } while ((Get-Date) -lt $deadline)

  throw "Timed out waiting for window: $Title"
}

function Save-WindowScreenshot {
  param(
    [IntPtr]$Hwnd,
    [string]$Path
  )

  [NativeMethods]::ShowWindow($Hwnd, 5) | Out-Null
  [NativeMethods]::SetForegroundWindow($Hwnd) | Out-Null
  Start-Sleep -Milliseconds 1200

  $rect = New-Object NativeMethods+RECT
  if (-not [NativeMethods]::GetWindowRect($Hwnd, [ref]$rect)) {
    throw "Failed to query window bounds"
  }

  $width = $rect.Right - $rect.Left
  $height = $rect.Bottom - $rect.Top
  if ($width -le 0 -or $height -le 0) {
    throw "Window bounds were invalid"
  }

  $bitmap = New-Object System.Drawing.Bitmap $width, $height
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
  $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
  $graphics.Dispose()
  $bitmap.Dispose()
}

foreach ($example in $examples) {
  $exePath = Join-Path $tempDir ($example.Name + ".exe")
  $pngPath = Join-Path $docsDir ($example.Name + ".png")

  Write-Host "Compiling $($example.Source)"
  Push-Location $examplesDir
  try {
    & nim c -d:release --out:$exePath $example.Source | Out-Host
  }
  finally {
    Pop-Location
  }
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to compile $($example.Source)"
  }

  Write-Host "Launching $($example.Name)"
  $process = Start-Process -FilePath $exePath -WorkingDirectory $repoRoot -PassThru
  try {
    $hwnd = Wait-ForWindow -Process $process -Title $example.Title
    Save-WindowScreenshot -Hwnd $hwnd -Path $pngPath
  }
  finally {
    if (-not $process.HasExited) {
      $null = $process.CloseMainWindow()
      if (-not $process.WaitForExit(3000)) {
        Stop-Process -Id $process.Id -Force
      }
    }
  }
}

Write-Host "Saved screenshots to $docsDir"
