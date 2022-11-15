# Package

version       = "0.1.0"
author        = "Kyle Coffey"
description   = "JSON Patch implementation in Nim"
license       = "MIT"
srcDir        = "src"


task test, "Runs the test suite":
  exec("nim c --outdir:bin -r tests/runTests.nim -- " & commandLineParams.join(" "))


# Dependencies

requires "nim >= 1.6.8"
