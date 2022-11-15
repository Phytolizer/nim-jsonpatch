import std/[
  strformat,
  strutils,
]

import jansson as json


proc decode(s: string): string =
  result = ""
  var i = 0
  while i < s.len:
    let c = s[i]
    case c
    of '~':
      i += 1
      case s[i]
      of '0':
        result.add '~'
      of '1':
        result.add '/'
      else:
        raise newException(ValueError, "bad escape")
    else:
      result.add c

    i += 1


proc splitPointer(p: string): seq[string] =
  result = @[]
  var elem = ""
  for c in p:
    case c
    of '/':
      if result.len > 0 or elem.len > 0:
        result.add elem
      elem = ""
    else:
      elem.add c
  if elem.len > 0:
    result.add elem


type Parent* = object
  value*: ptr json.t
  case kind*: json.valueType
  of JSON_OBJECT:
    member*: string
  of JSON_ARRAY:
    index*: uint
  else:
    discard


proc getChild*(parent: Parent): ptr json.t =
  case parent.kind
  of JSON_OBJECT:
    parent.value.objectGet(parent.member.cstring)
  of JSON_ARRAY:
    parent.value.arrayGet(parent.index)
  else:
    raiseAssert "unreachable"


proc followPointer*(obj: ptr json.t, rawPath: string): Parent =
  var target = obj
  result = Parent(value: obj)
  let path = rawPath.splitPointer()
  for elem in path:
    let elem = elem.decode()
    if target.isNil:
      raise newException(ValueError, fmt"object key {elem} nonexistent")
    case json.typeof(target)
    of JSON_OBJECT:
      let value = target.objectGet(elem.cstring)
      result = Parent(value: target, kind: JSON_OBJECT, member: elem)
      target = value
    of JSON_ARRAY:
      let index = if elem == "-":
        target.arraySize()
      else:
        elem.parseUInt
      let value = target.arrayGet(index)
      result = Parent(value: target, kind: JSON_ARRAY, index: index)
      target = value
    else:
      raise newException(ValueError, fmt"type {json.typeof(target)} not indexable")
