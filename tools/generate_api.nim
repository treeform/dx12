## IDL-based Nim code generator for DirectX 12 bindings.
## Reads all .idl files from idl/ and generates one .nim file per .idl in src/dx12/.
## Also generates the src/dx12.nim switchboard.
##
## Usage: nim r tools/generate_api.nim

import std/[os, strutils, strformat, sets, tables, sequtils]
import idl

const
  idlFileOrder = [
    "dxgicommon.idl",
    "dxgiformat.idl",
    "dxgitype.idl",
    "dxgi.idl",
    "dxgi1_2.idl",
    "dxgi1_3.idl",
    "dxgi1_4.idl",
    "dxgi1_5.idl",
    "dxgi1_6.idl",
    "d3dcommon.idl",
    "d3d12.idl",
    "d3d12shader.idl",
  ]

  skipImports = ["oaidl.idl", "ocidl.idl"].toHashSet()

  primitiveTypeMap = {
    "UINT": "uint32", "ULONG": "uint32", "DWORD": "uint32",
    "INT": "int32", "LONG": "int32",
    "FLOAT": "float32", "float": "float32",
    "UINT8": "uint8", "BYTE": "uint8",
    "UINT16": "uint16",
    "UINT64": "uint64",
    "INT64": "int64",
    "SIZE_T": "csize_t",
    "BOOL": "int32", "WINBOOL": "int32",
    "HRESULT": "int32",
    "HANDLE": "pointer", "HMONITOR": "pointer", "HMODULE": "pointer",
    "HDC": "pointer", "HWND": "pointer",
    "REFIID": "pointer", "REFGUID": "pointer",
    "LARGE_INTEGER": "int64", "LUID": "uint64",
    "SECURITY_ATTRIBUTES": "pointer",
  }.toTable()

  nimKeywords = ["type", "end", "object", "method", "proc", "var", "let",
    "const", "import", "export", "block", "break", "continue", "return",
    "result", "discard", "nil", "true", "false", "and", "or", "not", "in",
    "is", "of", "from", "addr", "cast", "ref", "ptr", "div", "mod", "shl",
    "shr", "xor", "template", "macro", "iterator", "converter", "func",
    "when", "if", "else", "elif", "while", "for", "case", "try", "except",
    "finally", "raise", "yield", "defer", "mixin", "bind", "concept",
    "static", "interface"].toHashSet()

  fieldRenames = {"Type": "typ", "Begin": "start", "End": "finish",
                  "ptr": "ptrValue", "type": "typ", "object": "objectField",
                  "method": "methodField"}.toTable()

type
  TypeRegistry = object
    enumNames: HashSet[string]
    structNames: HashSet[string]
    comNames: HashSet[string]
    typedefMap: Table[string, string]  # alias -> original
    typeToModule: Table[string, string]  # typeName -> nim module name

  VtableInfo = Table[string, int]  # interfaceName -> totalMethodCount

proc idlToNimModule(filename: string): string =
  result = filename.replace(".idl", "")
  if result == "d3d12":
    result = "d3d12_api"

proc sanitizeFieldName(name: string): string =
  if name in fieldRenames:
    return fieldRenames[name]
  if name.toLowerAscii() in nimKeywords:
    return name & "Field"
  if name.startsWith("_"):
    return "f" & name  # _11 -> f_11
  result = name

proc toCamelCase(name: string): string =
  if name.len == 0: return name
  var upperRun = 0
  for c in name:
    if c.isUpperAscii(): inc upperRun
    else: break
  if upperRun == 0: return name
  if upperRun == 1:
    return name[0..0].toLowerAscii() & name[1..^1]
  if upperRun >= name.len:
    return name.toLowerAscii()
  return name[0..<upperRun-1].toLowerAscii() & name[upperRun-1..^1]

proc mapCType(cType: string, reg: TypeRegistry): string =
  let t = cType.strip()

  if t in primitiveTypeMap:
    return primitiveTypeMap[t]

  # Strip const qualifier for lookup
  var base = t
  if base.startsWith("const "):
    base = base[6..^1].strip()

  # Pointer types
  if t == "void *" or t == "void*" or t == "const void *" or t == "const void*":
    return "pointer"
  if t == "void **" or t == "void**":
    return "ptr pointer"
  if t == "const char *":
    return "cstring"
  if "WCHAR" in t:
    return "pointer"

  # COM interface pointer: "IFoo *" -> IFoo (already ptr object)
  for name in reg.comNames:
    if t == name & " *" or t == name & "*" or t == "const " & name & " *":
      return name
    if t == name & " *const *" or t == name & " * const *":
      return "ptr " & name

  # Struct pointer: "TYPE *" -> ptr TYPE
  for name in reg.structNames:
    if t == name & " *" or t == "const " & name & " *":
      return "ptr " & name
    if t == name or t == "const " & name:
      return name

  # Enum types -> uint32
  if t in reg.enumNames or base in reg.enumNames:
    return "uint32"

  # Typedef resolution
  if t in reg.typedefMap:
    return mapCType(reg.typedefMap[t], reg)
  if base in reg.typedefMap:
    return mapCType(reg.typedefMap[base], reg)

  # Primitive pointer: "UINT *" etc
  for (cName, nimName) in primitiveTypeMap.pairs:
    if t == cName & " *" or t == "const " & cName & " *":
      return "ptr " & nimName

  # Generic pointer fallback
  if "*" in t:
    return "pointer"

  # Check if it's a known struct/COM by value
  if t in reg.structNames: return t
  if base in reg.structNames: return base
  if t in reg.comNames: return t

  return "pointer"

proc mapReturnType(cType: string, reg: TypeRegistry): string =
  let t = cType.strip()
  if t == "HRESULT": return "int32"
  if t == "void": return ""
  if t == "void *" or t == "void*": return "pointer"
  if t in primitiveTypeMap: return primitiveTypeMap[t]
  if t in reg.enumNames: return "uint32"
  if t in reg.comNames: return t
  if t in reg.structNames: return ""  # struct return by value — skip
  if t in reg.typedefMap:
    return mapReturnType(reg.typedefMap[t], reg)
  return ""

proc mapConstValue(cType, value: string): string =
  var v = value.strip()
  if v.len == 0: return "0"
  # Remove trailing L suffix from numeric literals only
  if v.endsWith("L") and v.len > 1 and (v[0] in {'0'..'9'} or v[0] == '-'):
    v = v[0..^2]
  # If value is an identifier reference (not a number), keep as-is
  if v.len > 0 and (v[0].isAlphaAscii() or v[0] == '_'):
    return v
  # Expression with C operators
  if '|' in v or '(' in v or '<' in v:
    var expr = v.replace("|", " or ")
    expr = expr.replace("<<", " shl ")
    expr = expr.replace(">>", " shr ")
    while "  " in expr: expr = expr.replace("  ", " ")
    return expr.strip()
  # Hex
  if v.startsWith("0x") or v.startsWith("0X"):
    if cType.contains("INT") and not cType.contains("UINT"):
      return v & "'i32"
    return v & "'u32"
  # Negative
  if v.startsWith("-"):
    return v & "'i32"
  # Float
  if '.' in v or v.endsWith("f"):
    if v.endsWith("f"): v = v[0..^2]
    return v & "'f32"
  # Decimal
  if v.allIt(it in {'0'..'9'}):
    if cType.contains("INT") and not cType.contains("UINT"):
      return v & "'i32"
    return v & "'u32"
  return v

proc buildTypeRegistry(files: seq[IdlFile]): TypeRegistry =
  for f in files:
    let modName = idlToNimModule(f.filename)
    for e in f.enums:
      result.enumNames.incl e.name
      result.typeToModule[e.name] = modName
    for s in f.structs:
      result.structNames.incl s.name
      result.typeToModule[s.name] = modName
    for iface in f.interfaces:
      result.comNames.incl iface.name
      result.typeToModule[iface.name] = modName
    for fwd in f.forwardDecls:
      result.comNames.incl fwd
    for td in f.typedefs:
      result.typedefMap[td.name] = td.aliasOf
      if td.aliasOf in result.comNames:
        result.comNames.incl td.name

proc buildVtableInfo(files: seq[IdlFile]): VtableInfo =
  result["IUnknown"] = 3
  for f in files:
    for iface in f.interfaces:
      let base = iface.base
      let parentCount = result.getOrDefault(base, 3)
      result[iface.name] = parentCount + iface.methods.len

proc generateNimFile(f: IdlFile, reg: TypeRegistry, vtable: VtableInfo): string =
  var lines: seq[string]
  let modName = idlToNimModule(f.filename)

  lines.add &"# Auto-generated from {f.filename} — do not edit manually."
  lines.add "# Regenerate with: nim r tools/generate_api.nim"
  lines.add ""

  # Imports
  var nimImports: seq[string]
  for imp in f.imports:
    if imp in skipImports: continue
    let nimMod = idlToNimModule(imp)
    nimImports.add nimMod

  var hasInterfaces = f.interfaces.len > 0 and
    f.interfaces.anyIt(it.methods.len > 0)
  if hasInterfaces:
    nimImports.add "vtable"

  if nimImports.len > 0:
    lines.add "import " & nimImports.join(", ")
    # Re-export IDL imports for transitive dependency support
    let reexports = nimImports.filterIt(it != "vtable")
    if reexports.len > 0:
      lines.add "export " & reexports.join(", ")
    lines.add ""

  # Constants
  var validConsts: seq[IdlConst]
  for c in f.consts:
    if c.name.startsWith("_"): continue
    validConsts.add c
  if validConsts.len > 0:
    lines.add "const"
    for c in validConsts:
      let val = mapConstValue(c.cType, c.value)
      lines.add &"  {c.name}* = {val}"
    lines.add ""

  # Enums
  for e in f.enums:
    if e.members.len == 0: continue
    lines.add &"# {e.name}"
    lines.add "const"
    for m in e.members:
      if m.name.startsWith("_"): continue
      let val = mapConstValue("UINT", m.value)
      lines.add &"  {m.name}* = {val}"
    lines.add ""

  # Forward declarations + COM interface stubs (before structs, so struct fields can reference them)
  var comNamesSeen: HashSet[string]
  var allComNames: seq[string]
  for fwd in f.forwardDecls:
    if fwd notin comNamesSeen:
      comNamesSeen.incl fwd
      allComNames.add fwd
  for iface in f.interfaces:
    if iface.name notin comNamesSeen:
      comNamesSeen.incl iface.name
      allComNames.add iface.name
  if allComNames.len > 0:
    lines.add "type"
    for name in allComNames:
      lines.add &"  {name}* = ptr object"
    lines.add ""

  # Structs
  if f.structs.len > 0:
    lines.add "type"
    for s in f.structs:
      lines.add &"  {s.name}* = object"
      var hasBitFields = false
      for field in s.fields:
        if field.name.len > 0 and field.name[0] in {'0'..'9'}:
          hasBitFields = true
          break
      if hasBitFields:
        lines.add "    data*: array[64, uint8]  # contains bit fields"
      else:
        var usedNames: HashSet[string]
        for field in s.fields:
          let nimType = if field.isArray and field.arraySize.len > 0:
            &"array[{field.arraySize}, {mapCType(field.cType, reg)}]"
          else:
            mapCType(field.cType, reg)
          var safeName = sanitizeFieldName(field.name)
          if safeName in usedNames:
            var suffix = 2
            while (safeName & $suffix) in usedNames: inc suffix
            safeName = safeName & $suffix
          usedNames.incl safeName
          lines.add &"    {safeName}*: {nimType}"
      lines.add ""

  # (COM interface stubs already emitted above, before structs)

  # Typedefs (after COM stubs so aliases can reference them)
  for td in f.typedefs:
    let target = td.aliasOf.strip()
    if target in reg.comNames:
      lines.add &"type {td.name}* = {target}"
    elif target in reg.structNames:
      lines.add &"type {td.name}* = {target}"
    elif target in primitiveTypeMap:
      lines.add &"type {td.name}* = {primitiveTypeMap[target]}"
    elif target in reg.enumNames:
      lines.add &"type {td.name}* = uint32"
  if f.typedefs.len > 0:
    lines.add ""

  # COM methods
  for iface in f.interfaces:
    if iface.methods.len == 0: continue
    let parentCount = vtable.getOrDefault(iface.base, 3)
    lines.add &"# --- {iface.name} methods ---"
    lines.add ""

    for idx, meth in iface.methods:
      let vtableIdx = parentCount + idx
      let nimName = toCamelCase(meth.name)
      let retType = meth.returnType
      let nimRetType = mapReturnType(retType, reg)
      let isHresult = retType == "HRESULT"
      let isVoid = retType == "void"
      let hasReturn = nimRetType.len > 0 and not isHresult

      # Skip struct-return-by-value methods (need special ABI — hand-written in extras)
      if not isHresult and not isVoid and nimRetType.len == 0:
        continue

      # Map parameters
      var nimParams: seq[string]
      var fParams: seq[string]
      var callArgs: seq[string]

      for pi, p in meth.params:
        let nimType = mapCType(p.cType, reg)
        var pname = p.name
        if pname.len == 0:
          pname = "param" & $pi
        let safeName = sanitizeFieldName(pname)
        nimParams.add &"{safeName}: {nimType}"
        fParams.add &"{safeName}: {nimType}"
        callArgs.add safeName

      # Build proc signature
      var sig = &"proc {nimName}*(self: {iface.name}"
      for np in nimParams:
        sig &= ", " & np
      sig &= ")"
      if hasReturn:
        sig &= ": " & nimRetType
      sig &= " ="

      # Build F type
      var fSig = &"  type F = proc(this: {iface.name}"
      for fp in fParams:
        fSig &= ", " & fp
      fSig &= "): "
      if isHresult: fSig &= "int32"
      elif isVoid: fSig &= "void"
      elif hasReturn: fSig &= nimRetType
      else: fSig &= "void"
      fSig &= " {.stdcall.}"

      # Build call
      var call: string
      if isHresult:
        if callArgs.len == 0:
          call = &"  callVtbl0Err(self, {vtableIdx}, F, \"{iface.name}.{meth.name}\")"
        else:
          call = &"  callVtblErr(self, {vtableIdx}, F, \"{iface.name}.{meth.name}\""
          for a in callArgs: call &= ", " & a
          call &= ")"
      elif isVoid or not hasReturn:
        if callArgs.len == 0:
          call = &"  callVtbl0(self, {vtableIdx}, F)"
        else:
          call = &"  callVtbl(self, {vtableIdx}, F"
          for a in callArgs: call &= ", " & a
          call &= ")"
      else:  # value return
        if callArgs.len == 0:
          call = &"  callVtbl0(self, {vtableIdx}, F)"
        else:
          call = &"  callVtbl(self, {vtableIdx}, F"
          for a in callArgs: call &= ", " & a
          call &= ")"

      lines.add sig
      lines.add fSig
      lines.add call
      lines.add ""

  result = lines.join("\n") & "\n"

proc generateSwitchboard(modules: seq[string]): string =
  var lines: seq[string]
  lines.add "# Auto-generated — do not edit manually."
  lines.add "# Regenerate with: nim r tools/generate_api.nim"
  lines.add ""

  let genMods = modules.join(", ")
  lines.add &"import dx12/[{genMods}]"
  lines.add &"export {genMods}"
  lines.add ""
  lines.add "import dx12/[vtable, extras, context, codes]"
  lines.add "export vtable, extras, context, codes"
  lines.add ""

  result = lines.join("\n") & "\n"

proc main() =
  let scriptDir = parentDir(currentSourcePath())
  let idlDir = normalizedPath(scriptDir / ".." / "idl")
  let outDir = normalizedPath(scriptDir / ".." / "src" / "dx12")
  let dx12Path = normalizedPath(scriptDir / ".." / "src" / "dx12.nim")

  # Parse all IDL files in dependency order
  echo "Parsing IDL files..."
  var allFiles: seq[IdlFile]
  for f in idlFileOrder:
    let path = idlDir / f
    if not fileExists(path):
      echo &"  SKIP {f} (not found)"
      continue
    echo &"  {f}..."
    allFiles.add parseIdlFileFromPath(path)

  # Build cross-file registries
  echo "Building type registry..."
  let reg = buildTypeRegistry(allFiles)
  echo &"  {reg.enumNames.len} enums, {reg.structNames.len} structs, {reg.comNames.len} COM interfaces"

  echo "Building vtable info..."
  let vtable = buildVtableInfo(allFiles)

  # Generate one .nim per .idl
  createDir(outDir)
  var generatedModules: seq[string]

  for f in allFiles:
    let modName = idlToNimModule(f.filename)
    let outPath = outDir / (modName & ".nim")
    echo &"Generating: {outPath}"
    let content = generateNimFile(f, reg, vtable)
    writeFile(outPath, content)
    generatedModules.add modName

  # Generate switchboard
  echo &"Generating: {dx12Path}"
  writeFile(dx12Path, generateSwitchboard(generatedModules))

  # Summary
  var totalConsts, totalEnumMembers, totalStructs, totalIfaces, totalMethods = 0
  for f in allFiles:
    totalConsts += f.consts.len
    for e in f.enums: totalEnumMembers += e.members.len
    totalStructs += f.structs.len
    totalIfaces += f.interfaces.len
    for iface in f.interfaces: totalMethods += iface.methods.len

  echo ""
  echo "Done!"
  echo &"  Generated {generatedModules.len} modules + switchboard"
  echo &"  Constants:  {totalConsts}"
  echo &"  Enums:      {totalEnumMembers} values"
  echo &"  Structs:    {totalStructs}"
  echo &"  Interfaces: {totalIfaces}"
  echo &"  Methods:    {totalMethods}"

when isMainModule:
  main()
