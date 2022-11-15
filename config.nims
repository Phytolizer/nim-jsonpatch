import std/os


switch("gc", "orc")
when buildOS == "windows":
  switch("passC", "-I" & (thisDir() / "lib-win64"))
  switch("clibdir", thisDir() / "lib-win64")
  switch("passL", "-ljansson")
else:
  switch("passC", "-I" & (thisDir() / "lib-linux64"))
  switch("clibdir", thisDir() / "lib-linux64")
  switch("passL", "-ljansson")
