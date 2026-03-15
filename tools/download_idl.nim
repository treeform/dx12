## Downloads DirectX IDL files from Wine's GitLab repository.
## These are the source-of-truth definitions from which .h headers are generated.
## License: LGPL-2.1+ (Wine project)
##
## Usage: nim r -d:ssl tools/download_idl.nim

import std/[os, httpclient, strformat]

const
  baseUrl = "https://gitlab.winehq.org/wine/wine/-/raw/master/include/"

  idlFiles = [
    # DXGI foundation (bottom of dependency chain)
    "dxgicommon.idl",    # DXGI_SAMPLE_DESC, DXGI_RATIONAL
    "dxgiformat.idl",    # DXGI_FORMAT enum (~115 formats)
    "dxgitype.idl",      # DXGI_MODE_DESC, DXGI_RGB, imports dxgicommon+dxgiformat

    # DXGI interfaces (each imports the previous)
    "dxgi.idl",          # IDXGIFactory, IDXGISwapChain, IDXGIOutput, IDXGIAdapter
    "dxgi1_2.idl",       # IDXGIFactory2, IDXGISwapChain1, DXGI_SWAP_CHAIN_DESC1
    "dxgi1_3.idl",       # IDXGIFactory3, IDXGISwapChain2 (inheritance chain)
    "dxgi1_4.idl",       # IDXGIFactory4, IDXGISwapChain3
    "dxgi1_5.idl",       # IDXGIFactory5 (tearing support), DXGI_FEATURE
    "dxgi1_6.idl",       # IDXGIFactory6, IDXGIFactory7 (latest)

    # Direct3D common types
    "d3dcommon.idl",     # ID3DBlob (ID3D10Blob), D3D_FEATURE_LEVEL, D3D_PRIMITIVE_TOPOLOGY

    # Direct3D 12
    "d3d12.idl",         # The main D3D12 API
    "d3d12shader.idl",   # Shader reflection interfaces
  ]

proc main() =
  let scriptDir = parentDir(currentSourcePath())
  let idlDir = normalizedPath(scriptDir / ".." / "idl")
  createDir(idlDir)

  echo &"Downloading {idlFiles.len} IDL files from Wine GitLab..."
  echo &"Source: {baseUrl}"
  echo &"Destination: {idlDir}"
  echo ""

  var client = newHttpClient()
  defer: client.close()

  var downloaded = 0
  for f in idlFiles:
    let url = baseUrl & f
    let destPath = idlDir / f
    echo &"  {f}..."
    let content = client.getContent(url)
    writeFile(destPath, content)
    echo &"    -> {content.len} bytes"
    inc downloaded

  echo ""
  echo &"Done! Downloaded {downloaded} IDL files to {idlDir}/"

when isMainModule:
  main()
