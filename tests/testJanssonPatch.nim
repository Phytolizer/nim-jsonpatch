import std/[
  os,
  strformat,
  unittest,
]

import jansson as json
import jansson/patch


proc checkPatch(inputText: string, patchText: string, expectedText: string) =
  let input = json.loads(inputText.cstring, 0, nil)
  check not input.isNil
  defer: input.decref()
  let patch = json.loads(patchText.cstring, 0, nil)
  check not patch.isNil
  defer: patch.decref()
  let expected = json.loads(expectedText.cstring, 0, nil)
  check not expected.isNil
  defer: expected.decref()

  let actual = input.applyPatch(patch)
  defer: actual.decref()
  checkpoint(fmt"actual:   {actual.dumps(0)}")
  checkpoint(fmt"expected: {expected.dumps(0)}")
  check actual.equal(expected)


proc checkPatch(inputText: string, patchText: string) =
  let input = json.loads(inputText.cstring, JSON_REJECT_DUPLICATES, nil)
  require not input.isNil
  defer: input.decref()
  let patch = json.loads(patchText.cstring, JSON_REJECT_DUPLICATES, nil)
  if patch.isNil:
    raise newException(InvalidPatchError, "patch isn't valid JSON")
  defer: patch.decref()

  let actual = input.applyPatch(patch)
  actual.decref()


proc jsonPath(path: string): string =
  "tests" / "rfc6902" / path


suite "json patch":
  test "add object member":
    checkPatch(
      readFile(jsonPath "a1.json"),
      readFile(jsonPath "a1.patch.json"),
      readFile(jsonPath "a1.out.json")
    )

  test "add array member":
    checkPatch(
      readFile(jsonPath "a2.json"),
      readFile(jsonPath "a2.patch.json"),
      readFile(jsonPath "a2.out.json")
    )

  test "remove object member":
    checkPatch(
      readFile(jsonPath "a3.json"),
      readFile(jsonPath "a3.patch.json"),
      readFile(jsonPath "a3.out.json")
    )

  test "remove array member":
    checkPatch(
      readFile(jsonPath "a4.json"),
      readFile(jsonPath "a4.patch.json"),
      readFile(jsonPath "a4.out.json")
    )

  test "replace object member":
    checkPatch(
      readFile(jsonPath "a5.json"),
      readFile(jsonPath "a5.patch.json"),
      readFile(jsonPath "a5.out.json")
    )

  test "move object member":
    checkPatch(
      readFile(jsonPath "a6.json"),
      readFile(jsonPath "a6.patch.json"),
      readFile(jsonPath "a6.out.json")
    )

  test "move array element":
    checkPatch(
      readFile(jsonPath "a7.json"),
      readFile(jsonPath "a7.patch.json"),
      readFile(jsonPath "a7.out.json")
    )

  test "test value success":
    checkPatch(
      readFile(jsonPath "a8.json"),
      readFile(jsonPath "a8.patch.json")
    )

  test "test value error":
    expect(PatchTestFailError):
      checkPatch(
        readFile(jsonPath "a9.json"),
        readFile(jsonPath "a9.patch.json")
      )

  test "add nested member object":
    checkPatch(
      readFile(jsonPath "a10.json"),
      readFile(jsonPath "a10.patch.json"),
      readFile(jsonPath "a10.out.json")
    )

  test "ignore extraneous patch members":
    checkPatch(
      readFile(jsonPath "a11.json"),
      readFile(jsonPath "a11.patch.json"),
      readFile(jsonPath "a11.out.json")
    )

  test "add to nonexistent target":
    expect(InvalidPatchError):
      checkPatch(
        readFile(jsonPath "a12.json"),
        readFile(jsonPath "a12.patch.json"),
      )

  test "invalid patch":
    expect(InvalidPatchError):
      checkPatch(
        readFile(jsonPath "a13.json"),
        readFile(jsonPath "a13.patch.json"),
      )

  test "~ escape is correct":
    checkPatch(
      readFile(jsonPath "a14.json"),
      readFile(jsonPath "a14.patch.json"),
    )

  test "strings aren't numbers":
    expect(PatchTestFailError):
      checkPatch(
        readFile(jsonPath "a15.json"),
        readFile(jsonPath "a15.patch.json"),
      )

  test "add nested array value":
    checkPatch(
      readFile(jsonPath "a16.json"),
      readFile(jsonPath "a16.patch.json"),
      readFile(jsonPath "a16.out.json")
    )
