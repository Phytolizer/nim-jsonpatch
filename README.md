# JSON Patch

The JSON Patch is a standardized format for describing procedural changes
to JSON documents. It is specified by [RFC 6902](https://www.rfc-editor.org/rfc/rfc6902).

A patch document could look like this:

```json
[
  { "op": "test", "path": "/a/b/c", "value": "foo" },
  { "op": "remove", "path": "/a/b/c" },
  { "op": "add", "path": "/a/b/c", "value": [ "foo", "bar" ] },
  { "op": "replace", "path": "/a/b/c", "value": 42 },
  { "op": "move", "from": "/a/b/c", "path": "/a/b/d" },
  { "op": "copy", "from": "/a/b/d", "path": "/a/b/e" }
]
```

You can see a bunch of examples in the [tests/rfc6902](tests/rfc6902) directory.
The `*.json` files are the initial documents, `*.patch.json` describes a patch,
and `*.out.json` is the result.

If `*.out.json` is missing, then the patch is either just performing a "test",
or it is intended to fail for one reason or another.

## API

The API entry point is `applyPatch`, defined in `jansson/patch`. Call it with two JSON objects,
the first specifying the target document, the second specifying the patch.

The function can throw, so be sure to catch InvalidPatchError and/or PatchTestFailError.

## Dependencies

This library depends only on the [Jansson](https://github.com/akheron/jansson) C library.

## Bugs

There are likely a bunch of memory leaks everywhere, and the functions in [jansson.nim](src/jansson.nim)
are generally not memory safe; most of them just forward directly to their C counterparts.
