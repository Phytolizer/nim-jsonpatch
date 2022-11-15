import std/[
  strformat,
  unittest,
]

import jansson as json
import jansson/jsonPointer


suite "json pointer":
  test "root pointer":
    let obj = json.newObject()
    defer: obj.decref()

    let p = ""
    let actual = obj.followPointer(p)
    let expected = json.newObject()
    defer: expected.decref()

    check actual.value.equal(expected)

  test "object pointer":
    let obj = json.newObject()
    defer: obj.decref()
    discard obj.objectSetNew("test".cstring, json.newString("hello".cstring))

    let p = "/test"
    let actualParent = obj.followPointer(p)
    let actual = actualParent.value.objectGet(actualParent.member.cstring)
    let expected = json.newString("hello".cstring)
    defer: expected.decref()

    checkpoint(fmt"actual:   {actual.dumps(JSON_ENCODE_ANY)}")
    checkpoint(fmt"expected: {expected.dumps(JSON_ENCODE_ANY)}")
    check actual.equal(expected)

suite "rfc6901 example":
  const example = staticRead("rfc6901.json")

  let obj = json.loads(example.cstring, 0, nil)
  defer: obj.decref()

  type TestCase = object
    p: string
    expected: ptr json.t

  let cases = @[
    TestCase(p: "/foo", expected: json.loads("[\"bar\", \"baz\"]".cstring, 0, nil)),
    TestCase(p: "/foo/0", expected: json.newString("bar".cstring)),
    TestCase(p: "/", expected: json.newInteger(0)),
    TestCase(p: "/a~1b", expected: json.newInteger(1)),
    TestCase(p: "/c%d", expected: json.newInteger(2)),
    TestCase(p: "/e^f", expected: json.newInteger(3)),
    TestCase(p: "/g|h", expected: json.newInteger(4)),
    TestCase(p: "/i\\j", expected: json.newInteger(5)),
    TestCase(p: "/k\"l", expected: json.newInteger(6)),
    TestCase(p: "/ ", expected: json.newInteger(7)),
    TestCase(p: "/m~0n", expected: json.newInteger(8)),
  ]

  for c in cases:
    test fmt"pointer ""{c.p}""":
      defer: c.expected.decref()

      let actualParent = obj.followPointer(c.p)
      let actual = actualParent.getChild()
      checkpoint(fmt"actual:   {actual.dumps(JSON_ENCODE_ANY)}")
      checkpoint(fmt"expected: {c.expected.dumps(JSON_ENCODE_ANY)}")
      check actual.equal(c.expected)
