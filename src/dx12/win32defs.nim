## Minimal Win32 type and function definitions for dx12.
## Replaces the windy dependency for the core library.

type
  BOOL* = int32
  LONG* = int32
  DWORD* = uint32
  UINT* = uint32
  HRESULT* = LONG
  HANDLE* = int
  HWND* = HANDLE

{.push stdcall, dynlib: "kernel32".}

proc CreateEventW*(
  lpEventAttributes: pointer,
  bManualReset: BOOL,
  bInitialState: BOOL,
  lpName: pointer
): HANDLE {.importc.}

proc WaitForSingleObject*(
  hHandle: HANDLE,
  dwMilliseconds: DWORD
): DWORD {.importc.}

proc CloseHandle*(
  hObject: HANDLE
): BOOL {.importc.}

{.pop.}
