## Parses all IDL files from the idl/ folder and prints a summary.
## Uses the generic IDL parser from idl.nim.
##
## Usage: nim r tools/parse_idl.nim

import std/[os, strutils, strformat]
import idl

const idlFiles = [
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

proc main() =
  let scriptDir = parentDir(currentSourcePath())
  let idlDir = normalizedPath(scriptDir / ".." / "idl")

  var totalConsts = 0
  var totalEnums = 0
  var totalEnumMembers = 0
  var totalStructs = 0
  var totalInterfaces = 0
  var totalMethods = 0
  var totalTypedefs = 0

  for f in idlFiles:
    let path = idlDir / f
    if not fileExists(path):
      echo &"  SKIP {f} (not found)"
      continue

    let parsed = parseIdlFileFromPath(path)

    var methodCount = 0
    for iface in parsed.interfaces:
      methodCount += iface.methods.len

    var enumMemberCount = 0
    for e in parsed.enums:
      enumMemberCount += e.members.len

    echo &"  {f:<25} consts={parsed.consts.len:<5} enums={parsed.enums.len:<4} structs={parsed.structs.len:<4} ifaces={parsed.interfaces.len:<4} methods={methodCount:<5} typedefs={parsed.typedefs.len:<3}"

    totalConsts += parsed.consts.len
    totalEnums += parsed.enums.len
    totalEnumMembers += enumMemberCount
    totalStructs += parsed.structs.len
    totalInterfaces += parsed.interfaces.len
    totalMethods += methodCount
    totalTypedefs += parsed.typedefs.len

  echo ""
  echo "Totals:"
  echo &"  Constants:  {totalConsts}"
  echo &"  Enums:      {totalEnums} ({totalEnumMembers} members)"
  echo &"  Structs:    {totalStructs}"
  echo &"  Interfaces: {totalInterfaces}"
  echo &"  Methods:    {totalMethods}"
  echo &"  Typedefs:   {totalTypedefs}"

  # Print a sample interface to verify parsing quality
  echo ""
  echo "--- Sample: ID3D12Resource ---"
  let d3d12 = parseIdlFileFromPath(idlDir / "d3d12.idl")
  for iface in d3d12.interfaces:
    if iface.name == "ID3D12Resource":
      echo &"  uuid: {iface.uuid}"
      echo &"  base: {iface.base}"
      for m in iface.methods:
        var paramStrs: seq[string]
        for p in m.params:
          let dirStr = case p.dir
            of pdIn: "[in] "
            of pdOut: "[out] "
            of pdInOut: "[in,out] "
            of pdNone: ""
          paramStrs.add dirStr & p.cType & " " & p.name
        echo &"  {m.returnType} {m.name}({paramStrs.join(\", \")})"

when isMainModule:
  main()
