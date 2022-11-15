import std/[
  os,
  strformat,
  strutils,
]

when isMainModule:
  let doSanitize = commandLineParams().contains("san")
  var failures = 0
  for f in walkDirRec(getCurrentDir() / "tests"):
    let (_, name, ext) = f.splitFile()
    if not (name.startsWith("t") and ext == ".nim"):
      continue
    var cmd = "nim c --outDir:bin/tests --verbosity:0"
    if doSanitize:
      cmd &= " --passC:-fsanitize=address --passL:-fsanitize=address"
    cmd &= fmt" -r {f}"
    let status = execShellCmd cmd
    if status != 0:
      inc failures

  quit failures
