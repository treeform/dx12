## Generic IDL (Interface Definition Language) parser.
## Parses Wine/MIDL .idl files into a typed data structure.
## No code generation — just data.

import std/[strutils, tables]

type
  IdlParamDir* = enum
    pdNone, pdIn, pdOut, pdInOut

  IdlParam* = object
    name*: string
    cType*: string
    dir*: IdlParamDir
    isArray*: bool
    arraySize*: string

  IdlMethod* = object
    name*: string
    returnType*: string
    params*: seq[IdlParam]

  IdlInterface* = object
    name*: string
    uuid*: string
    base*: string
    methods*: seq[IdlMethod]

  IdlEnumMember* = object
    name*: string
    value*: string

  IdlEnum* = object
    name*: string
    members*: seq[IdlEnumMember]

  IdlField* = object
    name*: string
    cType*: string
    isArray*: bool
    arraySize*: string

  IdlStruct* = object
    name*: string
    fields*: seq[IdlField]

  IdlConst* = object
    name*: string
    cType*: string
    value*: string

  IdlTypedef* = object
    name*: string
    aliasOf*: string

  IdlFile* = object
    filename*: string
    imports*: seq[string]
    consts*: seq[IdlConst]
    enums*: seq[IdlEnum]
    structs*: seq[IdlStruct]
    interfaces*: seq[IdlInterface]
    typedefs*: seq[IdlTypedef]
    forwardDecls*: seq[string]

# --- Tokenizer helpers ---

proc skipWhitespace(s: string, pos: var int) =
  while pos < s.len and s[pos] in {' ', '\t', '\n', '\r'}:
    inc pos

proc skipBlockComment(s: string, pos: var int) =
  if pos + 1 < s.len and s[pos] == '/' and s[pos+1] == '*':
    pos += 2
    while pos + 1 < s.len:
      if s[pos] == '*' and s[pos+1] == '/':
        pos += 2
        return
      inc pos

proc skipLineComment(s: string, pos: var int) =
  if pos + 1 < s.len and s[pos] == '/' and s[pos+1] == '/':
    while pos < s.len and s[pos] != '\n':
      inc pos

proc skipCommentsAndWhitespace(s: string, pos: var int) =
  while pos < s.len:
    let oldPos = pos
    skipWhitespace(s, pos)
    skipBlockComment(s, pos)
    skipLineComment(s, pos)
    if pos == oldPos: break

proc readIdent(s: string, pos: var int): string =
  let start = pos
  while pos < s.len and (s[pos].isAlphaAscii() or s[pos] in {'0'..'9'} or s[pos] == '_'):
    inc pos
  result = s[start..<pos]

proc expect(s: string, pos: var int, ch: char) =
  skipCommentsAndWhitespace(s, pos)
  if pos < s.len and s[pos] == ch:
    inc pos
  else:
    let ctx = if pos < s.len: "got '" & $s[pos] & "'" else: "got EOF"
    raise newException(ValueError, "Expected '" & $ch & "' at pos " & $pos & ", " & ctx)

proc peek(s: string, pos: int): char =
  if pos < s.len: s[pos] else: '\0'

proc collectUntil(s: string, pos: var int, terminator: char): string =
  let start = pos
  while pos < s.len and s[pos] != terminator:
    inc pos
  result = s[start..<pos]

proc collectBalancedBraces(s: string, pos: var int): string =
  ## Expects pos to be right after '{'. Collects until matching '}'.
  var depth = 1
  let start = pos
  while pos < s.len and depth > 0:
    if s[pos] == '{': inc depth
    elif s[pos] == '}': dec depth
    if depth > 0: inc pos
  result = s[start..<pos]
  if pos < s.len: inc pos  # skip closing '}'

# --- Parsing ---

proc parseCppQuote(s: string, pos: var int) =
  # Skip cpp_quote("..."); — we don't need these
  pos += 9  # skip "cpp_quote"
  skipCommentsAndWhitespace(s, pos)
  if pos < s.len and s[pos] == '(':
    inc pos
    var depth = 1
    while pos < s.len and depth > 0:
      if s[pos] == '(': inc depth
      elif s[pos] == ')': dec depth
      inc pos
    # skip optional semicolon
    skipCommentsAndWhitespace(s, pos)
    if pos < s.len and s[pos] == ';': inc pos

proc parseImport(s: string, pos: var int): string =
  pos += 6  # skip "import"
  skipCommentsAndWhitespace(s, pos)
  if pos < s.len and s[pos] == '"':
    inc pos
    result = collectUntil(s, pos, '"')
    inc pos  # skip closing "
  skipCommentsAndWhitespace(s, pos)
  if pos < s.len and s[pos] == ';': inc pos

proc parseConst(s: string, pos: var int): IdlConst =
  pos += 5  # skip "const"
  skipCommentsAndWhitespace(s, pos)
  var tokens: seq[string]
  while pos < s.len:
    skipCommentsAndWhitespace(s, pos)
    if pos >= s.len: break
    if s[pos] == '=': break
    if s[pos] == ';': break
    let ident = readIdent(s, pos)
    if ident.len == 0:
      inc pos
      continue
    tokens.add ident
  if tokens.len >= 2:
    result.name = tokens[^1]
    result.cType = tokens[0..^2].join(" ")
  elif tokens.len == 1:
    result.name = tokens[0]
  skipCommentsAndWhitespace(s, pos)
  if pos < s.len and s[pos] == '=':
    inc pos
    skipCommentsAndWhitespace(s, pos)
    result.value = collectUntil(s, pos, ';').strip()
  if pos < s.len and s[pos] == ';': inc pos

proc parseEnumBody(body: string): seq[IdlEnumMember] =
  # Join all lines into one, split by comma to handle multi-line values
  var joined = ""
  for rawLine in body.splitLines():
    let line = rawLine.strip()
    if line.len == 0 or line.startsWith("//"): continue
    joined.add " " & line

  var autoValue = 0
  for part in joined.split(','):
    var entry = part.strip()
    if entry.len == 0: continue
    let eqIdx = entry.find('=')
    if eqIdx != -1:
      let name = entry[0..<eqIdx].strip()
      let value = entry[eqIdx+1..^1].strip()
      if name.len > 0:
        result.add IdlEnumMember(name: name, value: value)
        try:
          if value.startsWith("0x") or value.startsWith("0X"):
            autoValue = parseHexInt(value) + 1
          else:
            autoValue = parseInt(value) + 1
        except:
          inc autoValue
    else:
      let name = entry.strip()
      if name.len > 0 and (name[0].isAlphaAscii() or name[0] == '_'):
        result.add IdlEnumMember(name: name, value: $autoValue)
        inc autoValue

proc parseStructBody(body: string): seq[IdlField] =
  for rawLine in body.splitLines():
    var line = rawLine.strip()
    if line.len == 0 or line.startsWith("//"): continue
    if line.endsWith(";"): line = line[0..^2].strip()
    if line.len == 0: continue

    var fieldName = ""
    var fieldType = ""
    var isArray = false
    var arraySize = ""

    # Handle array: "TYPE name[SIZE]"
    let bracketIdx = line.find('[')
    if bracketIdx != -1:
      isArray = true
      let closeBracket = line.find(']', bracketIdx)
      if closeBracket != -1:
        arraySize = line[bracketIdx+1..<closeBracket]
      line = line[0..<bracketIdx].strip()

    # Last word is the name, everything before is the type
    var tokens = line.splitWhitespace()
    if tokens.len < 2:
      continue
    fieldName = tokens[^1]
    while fieldName.startsWith("*"):
      fieldName = fieldName[1..^1]
      tokens[^2] = tokens[^2] & " *"
    fieldType = tokens[0..^2].join(" ")

    if fieldName.len > 0:
      result.add IdlField(name: fieldName, cType: fieldType, isArray: isArray, arraySize: arraySize)

proc parseMethodParams(paramStr: string): seq[IdlParam] =
  let trimmed = paramStr.strip()
  if trimmed.len == 0 or trimmed == "void": return

  var current = ""
  var parenDepth = 0
  var bracketDepth = 0
  var params: seq[string]
  for ch in trimmed:
    case ch
    of '(': inc parenDepth; current.add ch
    of ')': dec parenDepth; current.add ch
    of '[': inc bracketDepth; current.add ch
    of ']': dec bracketDepth; current.add ch
    of ',':
      if parenDepth == 0 and bracketDepth == 0:
        params.add current.strip()
        current = ""
      else:
        current.add ch
    else: current.add ch
  if current.strip().len > 0:
    params.add current.strip()

  for p in params:
    var param = IdlParam()
    var rest = p.strip()

    # Parse direction annotations: [in], [out], [in, out], [in, out, size_is(...)], etc.
    while rest.startsWith("["):
      let closeBracket = rest.find(']')
      if closeBracket == -1: break
      let annotation = rest[1..<closeBracket].toLowerAscii()
      if "out" in annotation and "in" in annotation:
        param.dir = pdInOut
      elif "out" in annotation:
        param.dir = pdOut
      elif "in" in annotation:
        param.dir = pdIn
      rest = rest[closeBracket+1..^1].strip()

    # Handle array: name[SIZE]
    let bracketIdx = rest.find('[')
    if bracketIdx != -1:
      param.isArray = true
      let closeBracket = rest.find(']', bracketIdx)
      if closeBracket != -1:
        param.arraySize = rest[bracketIdx+1..<closeBracket]
      rest = rest[0..<bracketIdx].strip()

    # Split "TYPE name" — last identifier is the name
    var tokens = rest.splitWhitespace()
    if tokens.len >= 2:
      param.name = tokens[^1]
      while param.name.startsWith("*"):
        param.name = param.name[1..^1]
        if tokens.len >= 2:
          tokens[^2] = tokens[^2] & " *"
      param.cType = tokens[0..^2].join(" ")
    elif tokens.len == 1:
      param.cType = tokens[0]

    result.add param

proc parseInterfaceMethods(body: string): seq[IdlMethod] =
  # Each method: "RETURN_TYPE MethodName(PARAMS);"
  # Methods can span multiple lines
  var combined = ""
  for line in body.splitLines():
    let trimmed = line.strip()
    if trimmed.len == 0 or trimmed.startsWith("//"): continue
    combined.add " " & trimmed

  # Split by semicolons to get individual method declarations
  for decl in combined.split(';'):
    let d = decl.strip()
    if d.len == 0: continue

    let parenOpen = d.find('(')
    if parenOpen == -1: continue
    let parenClose = d.rfind(')')
    if parenClose == -1: continue

    let leftPart = d[0..<parenOpen].strip()
    let paramStr = d[parenOpen+1..<parenClose]

    let tokens = leftPart.splitWhitespace()
    if tokens.len < 2: continue

    var meth = IdlMethod()
    var nameTokens = tokens
    meth.name = nameTokens[^1]
    while meth.name.startsWith("*"):
      meth.name = meth.name[1..^1]
      if nameTokens.len >= 2:
        nameTokens[^2] = nameTokens[^2] & " *"
    meth.returnType = nameTokens[0..^2].join(" ")
    meth.params = parseMethodParams(paramStr)
    result.add meth

proc parseInterface(s: string, pos: var int, uuid: string): IdlInterface =
  pos += 9  # skip "interface"
  skipCommentsAndWhitespace(s, pos)
  result.name = readIdent(s, pos)
  result.uuid = uuid
  skipCommentsAndWhitespace(s, pos)

  # Check for " : BaseName" inheritance
  if pos < s.len and s[pos] == ':':
    inc pos
    skipCommentsAndWhitespace(s, pos)
    result.base = readIdent(s, pos)
    skipCommentsAndWhitespace(s, pos)

  if pos < s.len and s[pos] == '{':
    inc pos
    let body = collectBalancedBraces(s, pos)
    result.methods = parseInterfaceMethods(body)
  elif pos < s.len and s[pos] == ';':
    inc pos  # forward declaration

proc parseAttributeBlock(s: string, pos: var int): Table[string, string] =
  ## Parses [ uuid(...), object, local, ... ] attribute blocks.
  expect(s, pos, '[')
  var content = ""
  var depth = 1
  while pos < s.len and depth > 0:
    if s[pos] == '[': inc depth
    elif s[pos] == ']': dec depth
    if depth > 0:
      content.add s[pos]
    inc pos

  for part in content.split(','):
    let p = part.strip()
    let parenIdx = p.find('(')
    if parenIdx != -1:
      let key = p[0..<parenIdx].strip()
      let value = p[parenIdx+1..^1].strip(chars = {')', ' '})
      result[key] = value
    elif p.len > 0:
      result[p] = ""

proc parseTypedef(s: string, pos: var int, result_file: var IdlFile) =
  pos += 7  # skip "typedef"
  skipCommentsAndWhitespace(s, pos)

  let word = readIdent(s, pos)
  if word.len == 0:
    discard collectUntil(s, pos, ';')
    if pos < s.len: inc pos
    return
  skipCommentsAndWhitespace(s, pos)

  case word
  of "enum":
    let nameOrBrace = readIdent(s, pos)
    var enumName = nameOrBrace
    skipCommentsAndWhitespace(s, pos)
    if pos < s.len and s[pos] == '{':
      inc pos
      let body = collectBalancedBraces(s, pos)
      skipCommentsAndWhitespace(s, pos)
      # The closing name after }
      let closingName = readIdent(s, pos)
      if closingName.len > 0:
        enumName = closingName
      skipCommentsAndWhitespace(s, pos)
      if pos < s.len and s[pos] == ';': inc pos
      var e = IdlEnum(name: enumName)
      e.members = parseEnumBody(body)
      result_file.enums.add e

  of "struct":
    let nameOrBrace = readIdent(s, pos)
    var structName = nameOrBrace
    skipCommentsAndWhitespace(s, pos)
    if pos < s.len and s[pos] == '{':
      inc pos
      let body = collectBalancedBraces(s, pos)
      skipCommentsAndWhitespace(s, pos)
      let closingName = readIdent(s, pos)
      if closingName.len > 0:
        structName = closingName
      skipCommentsAndWhitespace(s, pos)
      if pos < s.len and s[pos] == ';': inc pos
      var st = IdlStruct(name: structName)
      st.fields = parseStructBody(body)
      result_file.structs.add st
    else:
      # "typedef struct NAME *ALIAS;" — pointer typedef, skip
      discard collectUntil(s, pos, ';')
      if pos < s.len: inc pos

  else:
    # Simple typedef: "typedef OldName NewName;"
    # word is the first type token. Collect until ';'
    var rest = collectUntil(s, pos, ';').strip()
    if pos < s.len: inc pos
    let tokens = rest.splitWhitespace()
    if tokens.len >= 1:
      let newName = tokens[^1].strip(chars = {'*', ';', ' '})
      var aliasOf = word
      if tokens.len >= 2:
        aliasOf = word & " " & tokens[0..^2].join(" ")
      if newName.len > 0:
        result_file.typedefs.add IdlTypedef(name: newName, aliasOf: aliasOf.strip())

proc parseIdlFile*(filename: string, content: string): IdlFile =
  result.filename = filename
  var pos = 0
  let s = content

  while pos < s.len:
    skipCommentsAndWhitespace(s, pos)
    if pos >= s.len: break

    # Attribute block [ ... ] — usually precedes an interface
    if s[pos] == '[':
      let attrs = parseAttributeBlock(s, pos)
      skipCommentsAndWhitespace(s, pos)

      if pos + 9 < s.len and s[pos..<pos+9] == "interface":
        let uuid = attrs.getOrDefault("uuid", "")
        let iface = parseInterface(s, pos, uuid)
        if iface.name.len > 0:
          result.interfaces.add iface
      else:
        # Attributed non-interface (e.g. [local] HRESULT __stdcall Func(...);)
        discard collectUntil(s, pos, ';')
        if pos < s.len: inc pos
      continue

    # cpp_quote(...)
    if pos + 9 <= s.len and s[pos..<pos+9] == "cpp_quote":
      parseCppQuote(s, pos)
      continue

    # import "file.idl";
    if pos + 6 <= s.len and s[pos..<pos+6] == "import":
      let imp = parseImport(s, pos)
      if imp.len > 0:
        result.imports.add imp
      continue

    # const TYPE NAME = VALUE;
    if pos + 5 <= s.len and s[pos..<pos+5] == "const":
      let c = parseConst(s, pos)
      if c.name.len > 0:
        result.consts.add c
      continue

    # typedef ...
    if pos + 7 <= s.len and s[pos..<pos+7] == "typedef":
      parseTypedef(s, pos, result)
      continue

    # Forward declaration: "interface Name;"
    if pos + 9 <= s.len and s[pos..<pos+9] == "interface":
      let saved = pos
      pos += 9
      skipCommentsAndWhitespace(s, pos)
      let name = readIdent(s, pos)
      skipCommentsAndWhitespace(s, pos)
      if pos < s.len and s[pos] == ';':
        inc pos
        if name.len > 0:
          result.forwardDecls.add name
      else:
        pos = saved
        inc pos
      continue

    # Skip unknown tokens
    inc pos

proc parseIdlFileFromPath*(path: string): IdlFile =
  let content = readFile(path)
  let filename = path.split('/')[^1].split('\\')[^1]
  result = parseIdlFile(filename, content)
