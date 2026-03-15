import std/[strutils, os, sequtils, sets, tables]

type
  ConstantDef = object
    name: string
    value: string

  EnumDef = object
    name: string
    members: seq[ConstantDef]

  FieldDef = object
    name: string
    nimType: string

  StructDef = object
    name: string
    fields: seq[FieldDef]
    isSimple: bool

  CParam = object
    cType: string
    name: string

  ComMethod = object
    ifaceName: string
    methodName: string
    returnType: string
    params: seq[CParam]
    vtableIdx: int

proc isHexDigit(c: char): bool =
  c in {'0'..'9', 'a'..'f', 'A'..'F'}

proc stripOuterParens(s: string): string =
  var v = s.strip()
  while v.len >= 2 and v[0] == '(':
    var depth = 0
    var matchEnd = -1
    for i, c in v:
      if c == '(': inc depth
      elif c == ')':
        dec depth
        if depth == 0:
          matchEnd = i
          break
    if matchEnd == v.len - 1:
      v = v[1..^2].strip()
    else:
      break
  result = v

proc convertCExpr(raw: string): string =
  ## Converts a C numeric expression to Nim syntax.
  ## Handles hex/decimal literals, |, <<, >>, *, and constant references.
  var v = stripOuterParens(raw).strip()

  v = v.replace(" | ", " or ")
  v = v.replace("| ", "or ")
  v = v.replace(" |", " or")
  v = v.replace("|", " or ")
  v = v.replace("<<", " shl ")
  v = v.replace(">>", " shr ")

  while "  " in v:
    v = v.replace("  ", " ")
  v = v.strip()

  # Now add 'u32 suffixes to numeric literals
  result = ""
  var i = 0
  while i < v.len:
    # Hex literal
    if i + 1 < v.len and v[i] == '0' and v[i+1] in {'x', 'X'}:
      var hexEnd = i + 2
      while hexEnd < v.len and v[hexEnd].isHexDigit():
        inc hexEnd
      result.add v[i..<hexEnd]
      result.add "'u32"
      i = hexEnd
    # Decimal literal at a word boundary (not part of an identifier)
    elif v[i] in {'0'..'9'} and (i == 0 or not (v[i-1].isAlphaAscii() or v[i-1] == '_')):
      var numEnd = i
      while numEnd < v.len and v[numEnd] in {'0'..'9'}:
        inc numEnd
      # Make sure it's not followed by an identifier char
      if numEnd >= v.len or not (v[numEnd].isAlphaAscii() or v[numEnd] == '_'):
        result.add v[i..<numEnd]
        result.add "'u32"
        i = numEnd
      else:
        result.add v[i]
        inc i
    else:
      result.add v[i]
      inc i

proc classifyAndConvert(raw: string): string =
  ## Converts a C constant value to a Nim constant expression with type suffix.
  var v = stripOuterParens(raw).strip()

  if v.len == 0:
    return "0'u32"

  # Float literal: ends in 'f' like 1.0f, 3.402823466e+38f
  if v.endsWith("f") and ('.' in v or 'e' in v or 'E' in v):
    return v[0..^2] & "'f32"

  # Negative integer
  if v.startsWith("-") and v.len > 1:
    let inner = v[1..^1].strip()
    if inner.allIt(it in {'0'..'9'}):
      return v & "'i32"

  # Simple hex literal
  if v.startsWith("0x") or v.startsWith("0X"):
    let hexPart = v[2..^1]
    if hexPart.len > 0 and hexPart.allIt(it.isHexDigit()):
      return v & "'u32"

  # Simple decimal integer
  if v.allIt(it in {'0'..'9'}):
    return v & "'u32"

  # Complex expression - convert operators and add type suffixes
  if "|" in v or "<<" in v or ">>" in v or "*" in v:
    return convertCExpr(v)

  # Reference to another constant (identifier)
  if v[0].isAlphaAscii() or v[0] == '_':
    if v.allIt(it.isAlphaAscii() or it in {'0'..'9'} or it == '_'):
      return v

  # Fallback
  return v

proc parseDefineConstants(content: string): seq[ConstantDef] =
  ## Parses #define NAME (value) lines from the header.
  ## Skips function-like macros (NAME immediately followed by '('),
  ## multi-line macros (ending with \), and non-D3D12/DXGI names.
  for rawLine in content.splitLines():
    let line = rawLine.strip()
    if not line.startsWith("#define "):
      continue

    # Skip multi-line macros
    if line.endsWith("\\"):
      continue

    let rest = line[8..^1]  # after "#define "

    # Extract the macro name
    var nameEnd = 0
    while nameEnd < rest.len and (rest[nameEnd].isAlphaAscii() or rest[nameEnd] in {'0'..'9'} or rest[nameEnd] == '_'):
      inc nameEnd

    if nameEnd == 0 or nameEnd >= rest.len:
      continue

    let name = rest[0..<nameEnd]

    # Skip function-like macros: '(' immediately after name (no space)
    if rest[nameEnd] == '(':
      continue

    # Only include D3D12_ / DXGI_ / D3D_ prefixed names
    if not (name.startsWith("D3D12_") or name.startsWith("DXGI_") or name.startsWith("D3D_")):
      continue

    let valueStr = rest[nameEnd..^1].strip()
    if valueStr.len == 0:
      continue

    # Skip defines whose values contain macro invocations (IDENTIFIER followed by '(')
    var hasMacroCall = false
    for j in 0..<valueStr.len - 1:
      if (valueStr[j].isAlphaAscii() or valueStr[j] == '_') and j > 0:
        # Check if this is start of identifier followed eventually by '('
        discard
      if valueStr[j] == '(' and j > 0 and (valueStr[j-1].isAlphaAscii() or valueStr[j-1] in {'0'..'9'} or valueStr[j-1] == '_'):
        # Previous char is part of identifier → function call
        hasMacroCall = true
        break
    if hasMacroCall:
      continue

    let nimVal = classifyAndConvert(valueStr)
    result.add ConstantDef(name: name, value: nimVal)

proc parseEnums(content: string): seq[EnumDef] =
  ## Parses typedef enum NAME { ... } NAME; blocks.
  var pos = 0
  let marker = "typedef enum "
  while true:
    let idx = content.find(marker, pos)
    if idx == -1:
      break

    let nameStart = idx + marker.len
    var nameEnd = nameStart
    while nameEnd < content.len and (content[nameEnd].isAlphaAscii() or content[nameEnd] in {'0'..'9'} or content[nameEnd] == '_'):
      inc nameEnd

    let enumName = content[nameStart..<nameEnd]

    let braceStart = content.find('{', nameEnd)
    if braceStart == -1:
      pos = nameEnd
      continue

    var depth = 0
    var braceEnd = braceStart
    while braceEnd < content.len:
      if content[braceEnd] == '{': inc depth
      elif content[braceEnd] == '}':
        dec depth
        if depth == 0: break
      inc braceEnd

    if depth != 0:
      pos = braceEnd
      continue

    let body = content[braceStart + 1 ..< braceEnd]
    pos = braceEnd + 1

    var enumDef = EnumDef(name: enumName)

    for memberLine in body.splitLines():
      var trimmed = memberLine.strip()
      # Remove trailing comma
      if trimmed.endsWith(","):
        trimmed = trimmed[0..^2].strip()
      if trimmed.len == 0:
        continue

      let eqIdx = trimmed.find('=')
      if eqIdx == -1:
        continue

      let memberName = trimmed[0..<eqIdx].strip()
      let memberValue = trimmed[eqIdx + 1..^1].strip()

      if memberName.len == 0 or memberValue.len == 0:
        continue

      let nimVal = classifyAndConvert(memberValue)
      enumDef.members.add ConstantDef(name: memberName, value: nimVal)

    if enumDef.members.len > 0:
      result.add enumDef

const nimKeywords = ["type", "end", "object", "method", "proc", "var", "let",
  "const", "import", "export", "block", "break", "continue", "return",
  "result", "discard", "nil", "true", "false", "and", "or", "not", "in",
  "is", "of", "from", "addr", "cast", "ref", "ptr", "div", "mod", "shl",
  "shr", "xor", "template", "macro", "iterator", "converter", "func",
  "when", "if", "else", "elif", "while", "for", "case", "try", "except",
  "finally", "raise", "yield", "defer", "mixin", "bind", "concept",
  "static", "interface"].toHashSet()

const primitiveTypeMap = {
  "UINT": "uint32",
  "INT": "int32",
  "FLOAT": "float32",
  "UINT8": "uint8",
  "UINT16": "uint16",
  "UINT64": "uint64",
  "INT64": "int64",
  "SIZE_T": "csize_t",
  "WINBOOL": "int32",
  "BOOL": "int32",
  "BYTE": "uint8",
  "DXGI_FORMAT": "uint32",
  "D3D12_GPU_VIRTUAL_ADDRESS": "uint64",
  "D3D_FEATURE_LEVEL": "uint32",
  "D3D_PRIMITIVE_TOPOLOGY": "uint32",
  "DXGI_SAMPLE_DESC": "",  # not a primitive — exclude
  "LONG_PTR": "int64",
}.toTable()

const fieldRenames = {
  "Type": "typ",
  "Begin": "start",
  "End": "finish",
  "ptr": "ptrValue",
}.toTable()

proc sanitizeFieldName(name: string): string =
  if name in fieldRenames:
    return fieldRenames[name]
  if name.toLowerAscii() in nimKeywords:
    return name & "Field"
  result = name

proc mapCTypeToNim(cType: string, enumNames: HashSet[string]): string =
  ## Returns the Nim type for a C type, or "" if the type is not simple/scalar.
  let clean = cType.strip()
  if clean in primitiveTypeMap:
    let mapped = primitiveTypeMap[clean]
    if mapped.len == 0:
      return ""  # explicitly excluded
    return mapped
  if clean in enumNames:
    return "uint32"
  return ""  # unknown / complex type

proc parseStructs(content: string, enumNames: HashSet[string]): seq[StructDef] =
  var pos = 0
  let marker = "typedef struct "
  while true:
    let idx = content.find(marker, pos)
    if idx == -1:
      break

    let nameStart = idx + marker.len
    var nameEnd = nameStart
    while nameEnd < content.len and (content[nameEnd].isAlphaAscii() or content[nameEnd] in {'0'..'9'} or content[nameEnd] == '_'):
      inc nameEnd

    let structName = content[nameStart..<nameEnd]

    let braceStart = content.find('{', nameEnd)
    if braceStart == -1:
      pos = nameEnd
      continue

    var depth = 0
    var braceEnd = braceStart
    while braceEnd < content.len:
      if content[braceEnd] == '{': inc depth
      elif content[braceEnd] == '}':
        dec depth
        if depth == 0: break
      inc braceEnd

    if depth != 0:
      pos = braceEnd
      continue

    let body = content[braceStart + 1 ..< braceEnd]
    pos = braceEnd + 1

    # Skip structs with unions
    if "union" in body:
      continue

    var sd = StructDef(name: structName, isSimple: true)

    for fieldLine in body.splitLines():
      var trimmed = fieldLine.strip()
      if trimmed.len == 0 or trimmed.startsWith("//") or trimmed.startsWith("#"):
        continue
      # Remove trailing semicolon
      if trimmed.endsWith(";"):
        trimmed = trimmed[0..^2].strip()
      if trimmed.len == 0:
        continue

      # Reject pointer fields
      if '*' in trimmed:
        sd.isSimple = false
        break

      # Reject array fields
      if '[' in trimmed:
        sd.isSimple = false
        break

      # Strip 'const' qualifier
      var fieldDecl = trimmed.replace("const ", "").strip()

      # Split "TYPE NAME" — last token is the field name, everything before is the type
      let tokens = fieldDecl.splitWhitespace()
      if tokens.len < 2:
        sd.isSimple = false
        break

      let fieldName = tokens[^1]
      let cType = tokens[0..^2].join(" ")

      let nimType = mapCTypeToNim(cType, enumNames)
      if nimType.len == 0:
        sd.isSimple = false
        break

      sd.fields.add FieldDef(
        name: sanitizeFieldName(fieldName),
        nimType: nimType,
      )

    if sd.isSimple and sd.fields.len > 0:
      result.add sd

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
  # e.g. RSSetViewports: upperRun=3 (R,S,S), lowercase first 2 → rsSetViewports
  return name[0..<upperRun-1].toLowerAscii() & name[upperRun-1..^1]

proc parseCParamString(s: string): CParam =
  var p = s.strip()
  if p.len == 0: return
  # Remove trailing array size like [4]
  let bracketIdx = p.find('[')
  if bracketIdx != -1:
    p = p[0..<bracketIdx].strip()
  # Find the last identifier (the parameter name)
  var nameEnd = p.len
  var nameStart = nameEnd
  while nameStart > 0 and (p[nameStart-1].isAlphaAscii() or p[nameStart-1] in {'0'..'9'} or p[nameStart-1] == '_'):
    dec nameStart
  if nameStart >= nameEnd:
    return CParam(cType: p, name: "")
  result.name = p[nameStart..<nameEnd]
  result.cType = p[0..<nameStart].strip()
  # Clean up pointer notation: "void **" or "TYPE *"
  if result.cType.endsWith("*"):
    discard # keep as-is
  # Handle "const" at end after stripping name (shouldn't happen but defensive)

proc parseStaticInlineMethods(content: string): seq[ComMethod] =
  ## Parses "static FORCEINLINE RET IFACE_METHOD(IFACE* This[,params...]) {" lines.
  let prefix = "static FORCEINLINE "
  var ifaceCounters: Table[string, int]
  for rawLine in content.splitLines():
    let line = rawLine.strip()
    if not line.startsWith(prefix):
      continue
    if not line.endsWith("{"):
      continue
    let rest = line[prefix.len..^1]  # "RETURN_TYPE FUNC_NAME(PARAMS) {"
    let parenIdx = rest.find('(')
    if parenIdx == -1: continue
    let leftPart = rest[0..<parenIdx].strip()
    let closeParenIdx = rest.find(')')
    if closeParenIdx == -1: continue
    let paramStr = rest[parenIdx+1..<closeParenIdx]
    # Parse params
    let paramParts = paramStr.split(',')
    if paramParts.len == 0: continue
    # First param: "InterfaceName* This" or "InterfaceName *This"
    let firstParam = paramParts[0].strip()
    var ifaceName = ""
    let starIdx = firstParam.find('*')
    if starIdx != -1:
      ifaceName = firstParam[0..<starIdx].strip()
    if ifaceName.len == 0: continue
    # Function name: find "IfaceName_" in leftPart
    let funcPrefix = ifaceName & "_"
    let funcIdx = leftPart.find(funcPrefix)
    if funcIdx == -1: continue
    let returnType = leftPart[0..<funcIdx].strip()
    let methodName = leftPart[funcIdx + funcPrefix.len..^1].strip()
    if methodName.len == 0: continue
    # Skip _Impl helper functions (for aggregate return methods)
    if methodName.endsWith("_Impl"): continue
    # Parse remaining params (skip This)
    var params: seq[CParam]
    for i in 1..<paramParts.len:
      let cp = parseCParamString(paramParts[i])
      if cp.name.len > 0:
        params.add cp
    let idx = ifaceCounters.getOrDefault(ifaceName, 0)
    ifaceCounters[ifaceName] = idx + 1
    result.add ComMethod(
      ifaceName: ifaceName,
      methodName: methodName,
      returnType: returnType,
      params: params,
      vtableIdx: idx,
    )

proc parseInheritanceChain(content: string): Table[string, string] =
  ## Parses "InterfaceName : public BaseName" from MIDL_INTERFACE sections.
  let marker = "MIDL_INTERFACE("
  var pos = 0
  while true:
    let idx = content.find(marker, pos)
    if idx == -1: break
    # Find the next line after MIDL_INTERFACE("...")
    let lineEnd = content.find('\n', idx)
    if lineEnd == -1: break
    let nextLineEnd = content.find('\n', lineEnd + 1)
    if nextLineEnd == -1: break
    let inheritLine = content[lineEnd+1..<nextLineEnd].strip()
    # Format: "InterfaceName : public BaseName"
    let colonIdx = inheritLine.find(':')
    if colonIdx != -1:
      let ifaceName = inheritLine[0..<colonIdx].strip()
      var basePart = inheritLine[colonIdx+1..^1].strip()
      basePart = basePart.replace("public ", "").strip()
      # Remove trailing { if present
      let braceIdx = basePart.find('{')
      if braceIdx != -1:
        basePart = basePart[0..<braceIdx].strip()
      if ifaceName.len > 0 and basePart.len > 0:
        result[ifaceName] = basePart
    pos = nextLineEnd

proc getOwnMethodStart(ifaceName: string, inheritance: Table[string, string],
                       totalCounts: Table[string, int]): int =
  ## Returns the vtable index where own methods start for an interface.
  if ifaceName notin inheritance:
    return 3  # Assume inherits from IUnknown with 3 methods
  let base = inheritance[ifaceName]
  if base == "IUnknown":
    return 3
  if base in totalCounts:
    return totalCounts[base]
  # Recurse: the base's total = base's ownStart + base's own method count
  # But if we don't have static inlines for the base, try its parent
  return getOwnMethodStart(base, inheritance, totalCounts) # fallback

const knownPrimitiveParams = {
  "UINT": "uint32",
  "INT": "int32",
  "FLOAT": "float32",
  "float": "float32",
  "UINT8": "uint8",
  "UINT16": "uint16",
  "UINT64": "uint64",
  "INT64": "int64",
  "SIZE_T": "csize_t",
  "WINBOOL": "int32",
  "BOOL": "int32",
  "BYTE": "uint8",
  "ULONG": "uint32",
  "DWORD": "uint32",
  "HANDLE": "pointer",
  "D3D12_GPU_VIRTUAL_ADDRESS": "uint64",
  "D3D12_PRIMITIVE_TOPOLOGY": "uint32",
  "D3D_PRIMITIVE_TOPOLOGY": "uint32",
  "DXGI_FORMAT": "uint32",
  "D3D_FEATURE_LEVEL": "uint32",
  "D3D12_COMMAND_LIST_TYPE": "uint32",
}.toTable()

proc mapParamType(cType: string, comNames, structNames, enumNames: HashSet[string]): string =
  let t = cType.strip()
  if t in knownPrimitiveParams:
    return knownPrimitiveParams[t]
  if t in enumNames:
    return "uint32"
  # Direct struct by value (with or without const)
  if t in structNames:
    return t
  if t.startsWith("const ") and t[6..^1] in structNames:
    return t[6..^1]
  # void pointers
  if t in ["void *", "void*", "const void *", "const void*", "void*const"]:
    return "pointer"
  if t in ["void **", "void**"]:
    return "ptr pointer"
  # GUID references
  if t in ["REFIID", "REFGUID"]:
    return "pointer"
  # WCHAR strings
  if "WCHAR" in t:
    return "pointer"
  # COM interface pointer: "ID3D12Xxx *" or "const ID3D12Xxx *"
  for name in comNames:
    if t == name & " *" or t == name & "*" or t == "const " & name & " *":
      return name
    if t == name & " *const *":
      return "ptr " & name
  # Struct pointer: "const D3D12_Xxx *" or "D3D12_Xxx *"
  for name in structNames:
    if t == "const " & name & " *" or t == name & " *":
      return "ptr " & name
  # Enum pointer: "TYPE *" where TYPE is an enum
  for name in enumNames:
    if t == name & " *":
      return "ptr uint32"
  # Primitive pointer: "UINT *", "UINT64 *", "FLOAT *"
  for (cName, nimName) in knownPrimitiveParams.pairs:
    if t == cName & " *" or t == "const " & cName & " *":
      return "ptr " & nimName
  # Generic pointer fallback
  if "*" in t:
    return "pointer"
  return "pointer"

proc mapReturnTypeToNim(cType: string): string =
  case cType
  of "HRESULT": return "int32"
  of "void": return ""
  of "UINT", "ULONG": return "uint32"
  of "UINT64", "D3D12_GPU_VIRTUAL_ADDRESS": return "uint64"
  of "D3D12_COMMAND_LIST_TYPE": return "uint32"
  else:
    if cType.startsWith("D3D12_") or cType.startsWith("DXGI_"):
      return ""  # struct return — skip these methods
    return ""

proc generateMethodWrapper(m: ComMethod, comNames, structNames, enumNames: HashSet[string]): string =
  let nimName = toCamelCase(m.methodName)
  let retType = m.returnType
  let nimRetType = mapReturnTypeToNim(retType)
  let isHresult = retType == "HRESULT"
  let isVoid = retType == "void"
  let hasReturn = nimRetType.len > 0 and not isHresult
  # Map parameters
  var nimParams: seq[tuple[name: string, typ: string]]
  var fParams: seq[tuple[name: string, typ: string]]
  fParams.add (name: "this", typ: m.ifaceName)
  for p in m.params:
    let nimType = mapParamType(p.cType, comNames, structNames, enumNames)
    let safeName = sanitizeFieldName(p.name)
    nimParams.add (name: safeName, typ: nimType)
    fParams.add (name: safeName, typ: nimType)
  # Build proc signature
  var sig = "proc " & nimName & "*(self: " & m.ifaceName
  for p in nimParams:
    sig &= ", " & p.name & ": " & p.typ
  sig &= ")"
  if hasReturn:
    sig &= ": " & nimRetType
  sig &= " ="
  # Build F type
  var fSig = "  type F = proc(this: " & m.ifaceName
  for i, p in nimParams:
    fSig &= ", " & p.name & ": " & p.typ
  fSig &= "): "
  if isHresult:
    fSig &= "int32"
  elif isVoid:
    fSig &= "void"
  elif hasReturn:
    fSig &= nimRetType
  else:
    fSig &= "void"
  fSig &= " {.stdcall.}"
  # Build call
  var call: string
  let idx = $m.vtableIdx
  if isHresult:
    if nimParams.len == 0:
      call = "  callVtbl0Err(self, " & idx & ", F, \"" & m.ifaceName & "." & m.methodName & "\")"
    else:
      call = "  callVtblErr(self, " & idx & ", F, \"" & m.ifaceName & "." & m.methodName & "\""
      for p in nimParams:
        call &= ", " & p.name
      call &= ")"
  elif isVoid:
    if nimParams.len == 0:
      call = "  callVtbl0(self, " & idx & ", F)"
    else:
      call = "  callVtbl(self, " & idx & ", F"
      for p in nimParams:
        call &= ", " & p.name
      call &= ")"
  elif hasReturn:
    if nimParams.len == 0:
      call = "  callVtbl0(self, " & idx & ", F)"
    else:
      call = "  callVtbl(self, " & idx & ", F"
      for p in nimParams:
        call &= ", " & p.name
      call &= ")"
  else:
    return ""  # skip
  result = sig & "\n" & fSig & "\n" & call

proc parseComInterfaces(content: string): seq[string] =
  ## Parses "typedef interface NAME NAME;" lines and returns unique interface names.
  var seen: HashSet[string]
  for rawLine in content.splitLines():
    let line = rawLine.strip()
    if not line.startsWith("typedef interface "):
      continue
    if not line.endsWith(";"):
      continue
    let rest = line[18..^2].strip()  # after "typedef interface ", before ";"
    let tokens = rest.splitWhitespace()
    if tokens.len != 2:
      continue
    if tokens[0] != tokens[1]:
      continue
    let name = tokens[0]
    if name notin seen:
      seen.incl name
      result.add name

proc generateComFile(interfaces: seq[string], ownMethods: seq[ComMethod],
                     comNames, structNames, enumNames: HashSet[string]): string =
  var lines: seq[string]
  lines.add "# Auto-generated COM interface stubs and methods — do not edit manually."
  lines.add "# Regenerate with: nim r tools/generate_api.nim"
  lines.add "#"
  lines.add "# Depends on: generated_structs (for struct types)"
  lines.add "# Depends on: callVtbl, callVtblErr, callVtbl0, callVtbl0Err templates"
  lines.add ""
  lines.add "import generated_structs"
  lines.add ""
  lines.add "type"
  for name in interfaces:
    lines.add "  " & name & "* = ptr object"
  lines.add ""

  lines.add "# --- vtable call templates ---"
  lines.add ""
  lines.add "template callVtbl0(iface: pointer, index: int, typ: typedesc): untyped ="
  lines.add "  let vtblPtr = cast[ptr ptr UncheckedArray[pointer]](iface)"
  lines.add "  let vtbl = vtblPtr[]"
  lines.add "  let fn = cast[typ](vtbl[index])"
  lines.add "  fn(iface)"
  lines.add ""
  lines.add "template callVtbl(iface: pointer, index: int, typ: typedesc, args: varargs[untyped]): untyped ="
  lines.add "  let vtblPtr = cast[ptr ptr UncheckedArray[pointer]](iface)"
  lines.add "  let vtbl = vtblPtr[]"
  lines.add "  let fn = cast[typ](vtbl[index])"
  lines.add "  fn(iface, args)"
  lines.add ""
  lines.add "template callVtbl0Err(iface: pointer, index: int, typ: typedesc, msg: string): untyped ="
  lines.add "  let vtblPtr = cast[ptr ptr UncheckedArray[pointer]](iface)"
  lines.add "  let vtbl = vtblPtr[]"
  lines.add "  let fn = cast[typ](vtbl[index])"
  lines.add "  let hr = fn(iface)"
  lines.add "  if hr < 0:"
  lines.add "    raise newException(Exception, msg & \" HRESULT \" & $hr)"
  lines.add ""
  lines.add "template callVtblErr(iface: pointer, index: int, typ: typedesc, msg: string, args: varargs[untyped]): untyped ="
  lines.add "  let vtblPtr = cast[ptr ptr UncheckedArray[pointer]](iface)"
  lines.add "  let vtbl = vtblPtr[]"
  lines.add "  let fn = cast[typ](vtbl[index])"
  lines.add "  let hr = fn(iface, args)"
  lines.add "  if hr < 0:"
  lines.add "    raise newException(Exception, msg & \" HRESULT \" & $hr)"
  lines.add ""

  # Group own methods by interface
  var methodsByIface: Table[string, seq[ComMethod]]
  for m in ownMethods:
    if m.ifaceName notin methodsByIface:
      methodsByIface[m.ifaceName] = @[]
    methodsByIface[m.ifaceName].add m

  # Generate methods in interface order
  for iface in interfaces:
    if iface notin methodsByIface: continue
    let methods = methodsByIface[iface]
    if methods.len == 0: continue
    lines.add "# --- " & iface & " methods ---"
    lines.add ""
    for m in methods:
      let wrapper = generateMethodWrapper(m, comNames, structNames, enumNames)
      if wrapper.len > 0:
        lines.add wrapper
        lines.add ""

  result = lines.join("\n") & "\n"

proc generateConstantsFile(defines: seq[ConstantDef], enums: seq[EnumDef]): string =
  var lines: seq[string]

  lines.add "# Auto-generated from d3d12.h — do not edit manually."
  lines.add "# Regenerate with: nim r tools/generate_api.nim"
  lines.add ""

  if defines.len > 0:
    lines.add "const"
    for d in defines:
      lines.add "  " & d.name & "* = " & d.value
    lines.add ""

  for e in enums:
    lines.add "# " & e.name
    lines.add "const"
    for m in e.members:
      lines.add "  " & m.name & "* = " & m.value
    lines.add ""

  result = lines.join("\n") & "\n"

proc generateStructsFile(structs: seq[StructDef]): string =
  var lines: seq[string]

  lines.add "# Auto-generated from d3d12.h — do not edit manually."
  lines.add "# Regenerate with: nim r tools/generate_api.nim"
  lines.add ""
  lines.add "type"

  for s in structs:
    lines.add "  " & s.name & "* = object"
    for f in s.fields:
      lines.add "    " & f.name & "*: " & f.nimType
    lines.add ""

  result = lines.join("\n") & "\n"

proc main() =
  let scriptDir = parentDir(currentSourcePath())
  let headersDir = normalizedPath(scriptDir / ".." / "headers")
  let outDir = normalizedPath(scriptDir / ".." / "src" / "dx12")
  let constantsPath = outDir / "generated_constants.nim"
  let structsPath = outDir / "generated_structs.nim"
  let comStubsPath = outDir / "generated_com.nim"

  let headerFiles = ["d3d12.h", "dxgi1_4.h", "d3d12shader.h"]

  var allContent = ""
  for hf in headerFiles:
    let path = normalizedPath(headersDir / hf)
    if not fileExists(path):
      echo "WARNING: Header not found: ", path
      continue
    echo "Reading: ", path
    allContent.add readFile(path)
    allContent.add "\n"

  echo "Parsing #define constants..."
  let defines = parseDefineConstants(allContent)
  echo "  Found ", defines.len, " #define constants"

  echo "Parsing enums..."
  let enums = parseEnums(allContent)
  var totalMembers = 0
  for e in enums:
    totalMembers += e.members.len
  echo "  Found ", enums.len, " enums with ", totalMembers, " total values"

  var enumNames: HashSet[string]
  for e in enums:
    enumNames.incl e.name

  echo "Parsing structs..."
  let structs = parseStructs(allContent, enumNames)
  echo "  Found ", structs.len, " simple structs"

  echo "Parsing COM interfaces..."
  let comInterfaces = parseComInterfaces(allContent)
  echo "  Found ", comInterfaces.len, " COM interfaces"

  let comNames = comInterfaces.toHashSet()
  let structNameSet = structs.mapIt(it.name).toHashSet()

  echo "Parsing COM methods (static inline wrappers)..."
  let allMethods = parseStaticInlineMethods(allContent)
  echo "  Found ", allMethods.len, " total method entries"

  echo "Parsing inheritance chain..."
  let inheritance = parseInheritanceChain(allContent)

  # Build total method counts per interface
  var totalCounts: Table[string, int]
  for m in allMethods:
    totalCounts[m.ifaceName] = totalCounts.getOrDefault(m.ifaceName, 0) + 1

  # Determine own methods for each interface (skip IUnknown methods)
  var ownMethods: seq[ComMethod]
  var ownCountByIface: Table[string, int]
  for m in allMethods:
    let ownStart = getOwnMethodStart(m.ifaceName, inheritance, totalCounts)
    if m.vtableIdx >= ownStart:
      ownMethods.add m
      ownCountByIface[m.ifaceName] = ownCountByIface.getOrDefault(m.ifaceName, 0) + 1

  var totalOwn = 0
  for _, c in ownCountByIface:
    totalOwn += c
  echo "  Own methods to generate: ", totalOwn

  createDir(outDir)

  echo "Generating: ", constantsPath
  writeFile(constantsPath, generateConstantsFile(defines, enums))

  echo "Generating: ", structsPath
  writeFile(structsPath, generateStructsFile(structs))

  echo "Generating: ", comStubsPath
  writeFile(comStubsPath, generateComFile(comInterfaces, ownMethods, comNames, structNameSet, enumNames))

  let dx12Path = normalizedPath(scriptDir / ".." / "src" / "dx12.nim")
  echo "Generating: ", dx12Path
  let dx12Content = [
    "# Auto-generated — do not edit manually.",
    "# Regenerate with: nim r tools/generate_api.nim",
    "",
    "import dx12/[generated_constants, generated_structs, generated_com]",
    "export generated_constants, generated_structs, generated_com",
    "",
  ].join("\n") & "\n"
  writeFile(dx12Path, dx12Content)

  echo "Done!"
  echo "  Constants:      ", defines.len + totalMembers
  echo "  Structs:        ", structs.len
  echo "  COM interfaces: ", comInterfaces.len
  echo "  COM methods:    ", totalOwn

when isMainModule:
  main()
