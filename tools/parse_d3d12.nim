

import std/[strutils, os]

type
  MethodInfo = object
    name: string
    returnType: string
    args: seq[string]

  InterfaceInfo = object
    name: string
    guid: string
    base: string
    methods: seq[MethodInfo]

proc normalizeSpaces(s: string): string =
  var buf = newStringOfCap(s.len)
  var prevSpace = false
  for ch in s:
    if ch in {' ', '\t', '\n', '\r'}:
      if not prevSpace:
        buf.add ' '
        prevSpace = true
    else:
      buf.add ch
      prevSpace = false
  result = buf.strip()

proc splitArguments(argBlock: string): seq[string] =
  let trimmed = argBlock.strip()
  if trimmed.len == 0 or trimmed == "void":
    return @[]
  var current = newStringOfCap(trimmed.len)
  var depth = 0
  for ch in trimmed:
    case ch
    of '(':
      inc depth
      current.add ch
    of ')':
      if depth > 0:
        dec depth
      current.add ch
    of ',':
      if depth == 0:
        let entry = normalizeSpaces(current)
        if entry.len > 0:
          result.add entry
        current.setLen(0)
      else:
        current.add ch
    else:
      current.add ch
  let entry = normalizeSpaces(current)
  if entry.len > 0:
    result.add entry
  return result

proc skipSpaces(s: string, start: int): int =
  var idx = start
  while idx < s.len and s[idx] in {' ', '\t', '\n', '\r'}:
    inc idx
  return idx

proc parseMethods(body: string): seq[MethodInfo] =
  var pos = 0
  let keyword = "virtual"
  let callconv = "STDMETHODCALLTYPE"
  while true:
    let vIdx = body.find(keyword, pos)
    if vIdx == -1:
      break
    var cursor = vIdx + keyword.len
    cursor = skipSpaces(body, cursor)
    let stIdx = body.find(callconv, cursor)
    if stIdx == -1:
      break
    let returnType = normalizeSpaces(body[cursor ..< stIdx])
    cursor = stIdx + callconv.len
    cursor = skipSpaces(body, cursor)
    var nameStart = cursor
    while cursor < body.len and (body[cursor].isAlphaNumeric or body[cursor] == '_'):
      inc cursor
    if nameStart >= cursor:
      pos = cursor
      continue
    let methodName = body[nameStart ..< cursor]
    cursor = skipSpaces(body, cursor)
    if cursor >= body.len or body[cursor] != '(':
      pos = cursor
      continue
    var depth = 1
    let argsStart = cursor + 1
    cursor += 1
    while cursor < body.len and depth > 0:
      if body[cursor] == '(':
        inc depth
      elif body[cursor] == ')':
        dec depth
      inc cursor
    if depth != 0:
      break
    let argsEnd = cursor - 1
    let argsText = body[argsStart ..< argsEnd]
    cursor = skipSpaces(body, cursor)
    if cursor >= body.len or body[cursor] != '=':
      pos = cursor
      continue
    let semiIdx = body.find(';', cursor)
    if semiIdx == -1:
      break
    cursor = semiIdx + 1
    pos = cursor
    result.add MethodInfo(
      name: methodName,
      returnType: returnType,
      args: splitArguments(argsText)
    )
  return result

proc parseInterfaces(content: string): seq[InterfaceInfo] =
  let marker = "MIDL_INTERFACE(\""
  var idx = 0
  while true:
    let startIdx = content.find(marker, idx)
    if startIdx == -1:
      break
    let guidStart = startIdx + marker.len
    let guidEnd = content.find('"', guidStart)
    if guidEnd == -1:
      break
    let guid = content[guidStart ..< guidEnd]
    let signatureStart = content.find(')', guidEnd)
    if signatureStart == -1:
      break
    let braceIdx = content.find('{', signatureStart)
    if braceIdx == -1:
      break
    let signature = content[signatureStart + 1 ..< braceIdx].strip()
    var ifaceName = signature
    var baseName = ""
    let colonIdx = signature.find(':')
    if colonIdx != -1:
      ifaceName = signature[0 ..< colonIdx].strip()
      baseName = signature[colonIdx + 1 .. ^1].replace("public", "").strip()
    var depth = 0
    var bodyEnd = braceIdx
    var i = braceIdx
    while i < content.len:
      if content[i] == '{':
        inc depth
      elif content[i] == '}':
        dec depth
        if depth == 0:
          bodyEnd = i
          break
      inc i
    if depth != 0:
      break
    let body = content[braceIdx + 1 ..< bodyEnd]
    idx = bodyEnd
    result.add InterfaceInfo(
      name: ifaceName,
      guid: guid,
      base: baseName,
      methods: parseMethods(body)
    )
  return result

proc main() =
  let scriptDir = parentDir(currentSourcePath())
  let headerPath = normalizedPath(scriptDir / ".." / "headers" / "d3d12.h")
  let content = readFile(headerPath)
  let interfaces = parseInterfaces(content)
  for iface in interfaces:
    echo iface.name & " (" & iface.guid & ")"
    if iface.base.len > 0:
      echo "  inherits: " & iface.base
    for m in iface.methods:
      echo "  - " & m.name & ": " & m.returnType
      if m.args.len == 0:
        echo "      args: (none)"
      else:
        for idx, arg in m.args:
          echo "      " & $(idx + 1) & ". " & arg

when isMainModule:
  main()
