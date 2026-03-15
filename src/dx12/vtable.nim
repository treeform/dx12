## COM vtable call templates for DirectX 12 bindings.

template callVtbl0*(iface: pointer, index: int, typ: typedesc): untyped =
  let vtblPtr = cast[ptr ptr UncheckedArray[pointer]](iface)
  let vtbl = vtblPtr[]
  let fn = cast[typ](vtbl[index])
  fn(iface)

template callVtbl*(iface: pointer, index: int, typ: typedesc, args: varargs[untyped]): untyped =
  let vtblPtr = cast[ptr ptr UncheckedArray[pointer]](iface)
  let vtbl = vtblPtr[]
  let fn = cast[typ](vtbl[index])
  fn(iface, args)

template callVtbl0Err*(iface: pointer, index: int, typ: typedesc, msg: string): untyped =
  let vtblPtr = cast[ptr ptr UncheckedArray[pointer]](iface)
  let vtbl = vtblPtr[]
  let fn = cast[typ](vtbl[index])
  let hr = fn(iface)
  if hr < 0:
    raise newException(Exception, msg & " HRESULT " & $hr)

template callVtblErr*(iface: pointer, index: int, typ: typedesc, msg: string, args: varargs[untyped]): untyped =
  let vtblPtr = cast[ptr ptr UncheckedArray[pointer]](iface)
  let vtbl = vtblPtr[]
  let fn = cast[typ](vtbl[index])
  let hr = fn(iface, args)
  if hr < 0:
    raise newException(Exception, msg & " HRESULT " & $hr)
