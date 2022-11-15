import std/[
  strformat,
  strutils,
]

import jansson as json
import jansson/jsonPointer


type InvalidPatchError* = object of ValueError
  ## A patch to be applied was invalid for some reason.
type PatchTestFailError* = object of CatchableError
  ## The patch was valid, but it was a "test" patch and the specified
  ## object did not match.


proc checkedFollowPointer(obj: ptr json.t, path: string, i: uint64): Parent =
  ## Follow a JSON pointer, wrapping the error in some more context.
  try:
    obj.followPointer(path)
  except ValueError:
    raise newException(InvalidPatchError, fmt".[{i}].path: {path}: {getCurrentExceptionMsg()}")


proc checkedGet(obj: ptr json.t, member: string, i: uint64): ptr json.t =
  ## Get a member from a JSON object, throwing instead of returning nil.
  result = obj.objectGet(member.cstring)
  if result.isNil:
    raise newException(InvalidPatchError, fmt".[{i}].{member} nonexistent")


proc checkedGetString(obj: ptr json.t, member: string, i: uint64): string =
  ## Get a member from a JSON object, and throw unless it's a JSON string.
  let raw = obj.checkedGet(member, i)
  if json.typeof(raw) != JSON_STRING:
    raise newException(InvalidPatchError, fmt".[{i}].{member} not string")
  $raw.stringValue


proc doRemove(obj: ptr json.t, path: string, i: uint64): ptr json.t =
  ## Remove the specified path from the object.
  let parent = obj.checkedFollowPointer(path, i)
  result = parent.getChild().incref()
  case parent.kind
  of JSON_OBJECT:
    if parent.value.objectDel(parent.member.cstring) == -1:
      raise newException(
        InvalidPatchError,
        fmt".[{i}].path: cannot remove nonexistent key ""{parent.member}"""
      )
  of JSON_ARRAY:
    if parent.value.arrayRemove(parent.index) == -1:
      raise newException(
        InvalidPatchError,
        fmt".[{i}].path: cannot remove nonexistent index ""{parent.index}"""
      )
  else:
    # TODO: the current implementation of Parent simply reuses the jansson value type,
    # but as not all of those are valid for a Parent, it might be better to specify
    # a different enum.
    raiseAssert "unreachable"


proc doAdd(obj: ptr json.t, path: string, i: uint64, value: ptr json.t) =
  ## Add the provided object to `obj` at `path`.
  let parent = obj.checkedFollowPointer(path, i)
  case parent.kind
  of JSON_OBJECT:
    discard parent.value.objectSet(parent.member.cstring, value)
  of JSON_ARRAY:
    discard parent.value.arrayInsert(parent.index, value)
  else:
    raiseAssert "unreachable"


proc applyPatch*(obj: ptr json.t, patch: ptr json.t): ptr json.t =
  ## Applies a JSON Patch (RFC 6902) to an existing JSON document.
  ##
  ## An example patch document:
  ## [
  ##   { "op": "test", "path": "/a/b/c", "value": "foo" },
  ##   { "op": "remove", "path": "/a/b/c" },
  ##   { "op": "add", "path": "/a/b/c", "value": [ "foo", "bar" ] },
  ##   { "op": "replace", "path": "/a/b/c", "value": 42 },
  ##   { "op": "move", "from": "/a/b/c", "path": "/a/b/d" },
  ##   { "op": "copy", "from": "/a/b/d", "path": "/a/b/e" }
  ## ]
  ##
  ## The "path" and "from" fields on these objects are JSON Pointers (RFC 6901).
  ## The pointer implementation is located in `jsonPointer.nim`.
  ##
  ## Read the RFC or the source code for more exact details.
  ##
  ## If this throws, the error will contain a `jq`-formatted path
  ## specifying which part of the patch caused the failure
  ## (or which test failed, in the case of `PatchTestFailError`s).
  if json.typeof(patch) != JSON_ARRAY:
    raise newException(InvalidPatchError, "top level is not array")

  result = json.deepCopy(obj)

  for i in 0 ..< patch.arraySize:
    let elem = patch.arrayGet(i.uint)
    if json.typeof(elem) != JSON_OBJECT:
      raise newException(InvalidPatchError, fmt".[{i}] not object")

    let op = elem.checkedGetString("op", i)

    let path = elem.checkedGetString("path", i)

    case op
    of "add":
      # does one of three things:
      # * if the target location is an array index, insert the value into the array there.
      # * if the target location is a non-existing object member, add it.
      # * if the target-location is an existing object member, replace it.
      let value = elem.checkedGet("value", i)
      result.doAdd(path, i, value)
    of "remove":
      # simply removes the object or array member specified.
      let removed = result.doRemove(path, i)
      removed.decref()
    of "replace":
      # equivalent to "remove" followed by "add" in the same location.
      # the behavior differs from "add" in that:
      # * the key/index must exist already.
      # * the new value does not push other array members around.
      let value = elem.checkedGet("value", i)
      let parent = result.checkedFollowPointer(path, i)
      case parent.kind
      of JSON_ARRAY:
        if parent.value.arraySet(parent.index, value) == -1:
          raise newException(
            InvalidPatchError,
            fmt".[{i}].path: cannot replace nonexistent index ""{parent.index}"""
          )
      of JSON_OBJECT:
        let existingChild = parent.getChild()
        if existingChild.isNil:
          raise newException(
            InvalidPatchError,
            fmt".[{i}].path: cannot replace nonexistent key ""{parent.member}"""
          )
        discard parent.value.objectSet(parent.member.cstring, value)
      else:
        raiseAssert "unreachable"
    of "move":
      # equivalent to "remove" followed by "add" in a different location.
      let fromPath = elem.checkedGetString("from", i)
      let removed = result.doRemove(fromPath, i)
      result.doAdd(path, i, removed)
    of "copy":
      # equivalent to "add", but takes a pointer instead of a direct value.
      let fromPath = elem.checkedGetString("from", i)
      let parent = result.checkedFollowPointer(fromPath, i)
      let value = parent.getChild().incref()
      result.doAdd(path, i, value)
    of "test":
      # this operation will throw if the object at "path" is not equal to "value".
      # it throws a distinct exception so that it can be handled separately from
      # patch validation errors.
      let value = elem.checkedGet("value", i)
      let parent = result.checkedFollowPointer(path, i)
      let actual = parent.getChild()
      if not actual.equal(value):
        raise newException(PatchTestFailError, fmt".[{i}]: test failed")
    else:
      raise newException(InvalidPatchError, fmt".[{i}].op: ""{op}"" invalid operation")
