# Generated @ 2022-11-10T22:08:13+00:00
# Command line:
#   /root/.nimble/pkgs/nimterop-0.6.13/nimterop/toast -n src/jansson.h -G @^_=z -Ejson_ -Ejansson_ -p -I ./build/include

# const 'jsonBooleanValue' has unsupported value 'jsonIsTrue'
# const 'jsonAutoT' has unsupported value 'jsonT _attribute_((cleanup(jsonDecrefp)))'
{.push hint[ConvFromXtoItselfNotNeeded]: off.}
import std/macros

proc c_free(p: pointer) {.importc: "free", header: "<stdlib.h>".}

macro defineEnum(typ: untyped): untyped =
  result = newNimNode(nnkStmtList)

  # Enum mapped to distinct cint
  result.add quote do:
    type `typ`* = distinct cint

  for i in ["+", "-", "*", "div", "mod", "shl", "shr", "or", "and", "xor", "<",
      "<=", "==", ">", ">="]:
    let
      ni = newIdentNode(i)
      typout = if i[0] in "<=>": newIdentNode("bool") else: typ # comparisons return bool
    if i[0] == '>': # cannot borrow `>` and `>=` from templates
      let
        nopp = if i.len == 2: newIdentNode("<=") else: newIdentNode("<")
      result.add quote do:
        proc `ni`*(x: `typ`, y: cint): `typout` = `nopp`(y, x)
        proc `ni`*(x: cint, y: `typ`): `typout` = `nopp`(y, x)
        proc `ni`*(x, y: `typ`): `typout` = `nopp`(y, x)
    else:
      result.add quote do:
        proc `ni`*(x: `typ`, y: cint): `typout` {.borrow.}
        proc `ni`*(x: cint, y: `typ`): `typout` {.borrow.}
        proc `ni`*(x, y: `typ`): `typout` {.borrow.}
    result.add quote do:
      proc `ni`*(x: `typ`, y: int): `typout` = `ni`(x, y.cint)
      proc `ni`*(x: int, y: `typ`): `typout` = `ni`(x.cint, y)

  let
    divop = newIdentNode("/")   # `/`()
    notop = newIdentNode("not") # `not`()
  result.add quote do:
    proc `divop`*(x, y: `typ`): `typ` = `typ`((x.float / y.float).cint)
    proc `divop`*(x: `typ`, y: cint): `typ` = `divop`(x, `typ`(y))
    proc `divop`*(x: cint, y: `typ`): `typ` = `divop`(`typ`(x), y)
    proc `divop`*(x: `typ`, y: int): `typ` = `divop`(x, y.cint)
    proc `divop`*(x: int, y: `typ`): `typ` = `divop`(x.cint, y)

    proc `notop`*(x: `typ`): `typ` {.borrow.}

type vaList* {.importc, header: "<stdarg.h>".} = object


{.pragma: impjanssonHdr, header: "jansson.h".}
{.experimental: "codeReordering".}
defineEnum(errorCode)
const
  JANSSON_MAJOR_VERSION* = 2
  JANSSON_MINOR_VERSION* = 14
  JANSSON_MICRO_VERSION* = 0
  JANSSON_VERSION* = "2.14"
  JANSSON_VERSIONHEX* = ((JANSSONMAJOR_VERSION shl
      typeof(JANSSON_MAJOR_VERSION)(16)) or
      typeof(JANSSON_MAJOR_VERSION)((JANSSON_MINORVERSION shl
      typeof(JANSSON_MAJOR_VERSION)(8))) or
      typeof(JANSSON_MAJOR_VERSION)((JANSSON_MICROVERSION shl
      typeof(JANSSON_MAJOR_VERSION)(0))))
  JANSSON_THREAD_SAFE_REFCOUNT* = 1
  JSON_ERROR_TEXT_LENGTH* = 160
  JSON_ERROR_SOURCE_LENGTH* = 80
  errorUnknown* = (0).errorCode
  errorOutOfMemory* = (errorUnknown + 1).errorCode
  errorStackOverflow* = (errorOutOfMemory + 1).errorCode
  errorCannotOpenFile* = (errorStackOverflow + 1).errorCode
  errorInvalidArgument* = (errorCannotOpenFile + 1).errorCode
  errorInvalidUtf8* = (errorInvalidArgument + 1).errorCode
  errorPrematureEndOfInput* = (errorInvalidUtf8 + 1).errorCode
  errorEndOfInputExpected* = (errorPrematureEndOfInput + 1).errorCode
  errorInvalidSyntax* = (errorEndOfInputExpected + 1).errorCode
  errorInvalidFormat* = (errorInvalidSyntax + 1).errorCode
  errorWrongType* = (errorInvalidFormat + 1).errorCode
  errorNullCharacter* = (errorWrongType + 1).errorCode
  errorNullValue* = (errorNullCharacter + 1).errorCode
  errorNullByteInKey* = (errorNullValue + 1).errorCode
  errorDuplicateKey* = (errorNullByteInKey + 1).errorCode
  errorNumericOverflow* = (errorDuplicateKey + 1).errorCode
  errorItemNotFound* = (errorNumericOverflow + 1).errorCode
  errorIndexOutOfRange* = (errorItemNotFound + 1).errorCode
  JSON_VALIDATE_ONLY* = 0x00000001
  JSON_STRICT* = 0x00000002
  JSON_REJECT_DUPLICATES* = 0x00000001
  JSON_DISABLE_EOF_CHECK* = 0x00000002
  JSON_DECODE_ANY* = 0x00000004
  JSON_DECODE_INT_AS_REAL* = 0x00000008
  JSON_ALLOW_NUL* = 0x00000010
  JSON_MAX_INDENT* = 0x0000001F
  JSON_COMPACT* = 0x00000020
  JSON_ENSURE_ASCII* = 0x00000040
  JSON_SORT_KEYS* = 0x00000080
  JSON_PRESERVE_ORDER* = 0x00000100
  JSON_ENCODE_ANY* = 0x00000200
  JSON_ESCAPE_SLASH* = 0x00000400
  JSON_EMBED* = 0x00010000
type
  valueType* = enum
    JSON_OBJECT = 0
    JSON_ARRAY
    JSON_STRING
    JSON_INTEGER
    JSON_REAL
    JSON_TRUE
    JSON_FALSE
    JSON_NULL
  t* {.bycopy, impjanssonHdr, importc: "struct json_t".} = object
    `type`*: valueType
    refcount*: uint

  errorT* {.bycopy, impjanssonHdr, importc: "struct json_error_t".} = object
    line*: cint
    column*: cint
    position*: cint
    source*: array[80, cchar]
    text*: array[160, cchar]

  loadCallbackT* {.impjanssonHdr, importc: "json_load_callback_t".} = proc (
      buffer: pointer; buflen: uint; data: pointer): uint {.cdecl.}
  dumpCallbackT* {.impjanssonHdr, importc: "json_dump_callback_t".} = proc (
      buffer: cstring; size: uint; data: pointer): cint {.cdecl.}
  mallocT* {.impjanssonHdr, importc: "json_malloc_t".} = proc (
      a1: uint): pointer {.
      cdecl.}
  freeT* {.impjanssonHdr, importc: "json_free_t".} = proc (
      a1: pointer) {.cdecl.}
proc typeofInternal(j: ptr t): cint {.importc: "json_typeof", cdecl, impjanssonHdr.}
proc typeof*(j: ptr t): valueType = j.typeofInternal.valueType
proc newObject*(): ptr t {.importc: "json_object", cdecl, impjanssonHdr.}
proc newArray*(): ptr t {.importc: "json_array", cdecl, impjanssonHdr.}
proc newString*(value: cstring): ptr t {.importc: "json_string", cdecl,
                                      impjanssonHdr.}
proc newString*(value: cstring, len: uint): ptr t {.importc: "json_stringn",
    cdecl, impjanssonHdr.}
proc newStringNoCheck*(value: cstring): ptr t {.importc: "json_string_nocheck",
    cdecl, impjanssonHdr.}
proc newStringNoCheck*(value: cstring, len: uint): ptr t {.
    importc: "json_stringn_nocheck", cdecl, impjanssonHdr.}
proc newInteger*(value: clonglong): ptr t {.importc: "json_integer", cdecl,
    impjanssonHdr.}
proc newReal*(value: cdouble): ptr t {.importc: "json_real", cdecl, impjanssonHdr.}
proc newTrue*(): ptr t {.importc: "json_true", cdecl, impjanssonHdr.}
proc newFalse*(): ptr t {.importc: "json_false", cdecl, impjanssonHdr.}
proc newNull*(): ptr t {.importc: "json_null", cdecl, impjanssonHdr.}
proc incref*(json: ptr t): ptr t {.importc: "json_incref", cdecl, impjanssonHdr.}
proc decref*(json: ptr t) {.importc: "json_decref", cdecl, impjanssonHdr.}
proc decrefp*(json: ptr ptr t) {.importc: "json_decrefp", cdecl, impjanssonHdr.}
proc objectSeed*(seed: uint) {.importc: "json_object_seed", cdecl,
                                impjanssonHdr.}
proc objectSize*(`object`: ptr t): uint {.importc: "json_object_size", cdecl,
    impjanssonHdr.}
proc objectGet*(`object`: ptr t; key: cstring): ptr t {.
    importc: "json_object_get", cdecl, impjanssonHdr.}
proc objectGetn*(`object`: ptr t; key: cstring; keyLen: uint): ptr t {.
    importc: "json_object_getn", cdecl, impjanssonHdr.}
proc objectSetNew*(`object`: ptr t; key: cstring; value: ptr t): cint {.
    importc: "json_object_set_new", cdecl, impjanssonHdr.}
proc objectSetnNew*(`object`: ptr t; key: cstring; keyLen: uint;
    value: ptr t): cint {.
    importc: "json_object_setn_new", cdecl, impjanssonHdr.}
proc objectSetNewNocheck*(`object`: ptr t; key: cstring; value: ptr t): cint {.
    importc: "json_object_set_new_nocheck", cdecl, impjanssonHdr.}
proc objectSetnNewNocheck*(`object`: ptr t; key: cstring; keyLen: uint;
                              value: ptr t): cint {.
    importc: "json_object_setn_new_nocheck", cdecl, impjanssonHdr.}
proc objectDel*(`object`: ptr t; key: cstring): cint {.
    importc: "json_object_del", cdecl, impjanssonHdr.}
proc objectDeln*(`object`: ptr t; key: cstring; keyLen: uint): cint {.
    importc: "json_object_deln", cdecl, impjanssonHdr.}
proc objectClear*(`object`: ptr t): cint {.importc: "json_object_clear", cdecl,
    impjanssonHdr.}
proc objectUpdate*(`object`: ptr t; other: ptr t): cint {.
    importc: "json_object_update", cdecl, impjanssonHdr.}
proc objectUpdateExisting*(`object`: ptr t; other: ptr t): cint {.
    importc: "json_object_update_existing", cdecl, impjanssonHdr.}
proc objectUpdateMissing*(`object`: ptr t; other: ptr t): cint {.
    importc: "json_object_update_missing", cdecl, impjanssonHdr.}
proc objectUpdateRecursive*(`object`: ptr t; other: ptr t): cint {.
    importc: "json_object_update_recursive", cdecl, impjanssonHdr.}
proc objectIter*(`object`: ptr t): pointer {.importc: "json_object_iter",
    cdecl, impjanssonHdr.}
proc objectIterAt*(`object`: ptr t; key: cstring): pointer {.
    importc: "json_object_iter_at", cdecl, impjanssonHdr.}
proc objectKeyToIter*(key: cstring): pointer {.
    importc: "json_object_key_to_iter", cdecl, impjanssonHdr.}
proc objectIterNext*(`object`: ptr t; iter: pointer): pointer {.
    importc: "json_object_iter_next", cdecl, impjanssonHdr.}
proc objectIterKey*(iter: pointer): cstring {.importc: "json_object_iter_key",
    cdecl, impjanssonHdr.}
proc objectIterKeyLen*(iter: pointer): uint {.
    importc: "json_object_iter_key_len", cdecl, impjanssonHdr.}
proc objectIterValue*(iter: pointer): ptr t {.
    importc: "json_object_iter_value", cdecl, impjanssonHdr.}
proc objectIterSetNew*(`object`: ptr t; iter: pointer; value: ptr t): cint {.
    importc: "json_object_iter_set_new", cdecl, impjanssonHdr.}
proc objectSet*(`object`: ptr t; key: cstring; value: ptr t): cint {.
    importc: "json_object_set", cdecl, impjanssonHdr.}
proc objectSetn*(`object`: ptr t; key: cstring; keyLen: uint;
    value: ptr t): cint {.
    importc: "json_object_setn", cdecl, impjanssonHdr.}
proc objectSetNocheck*(`object`: ptr t; key: cstring; value: ptr t): cint {.
    importc: "json_object_set_nocheck", cdecl, impjanssonHdr.}
proc objectSetnNocheck*(`object`: ptr t; key: cstring; keyLen: uint;
                          value: ptr t): cint {.
    importc: "json_object_setn_nocheck", cdecl, impjanssonHdr.}
proc objectIterSet*(`object`: ptr t; iter: pointer; value: ptr t): cint {.
    importc: "json_object_iter_set", cdecl, impjanssonHdr.}
proc objectUpdateNew*(`object`: ptr t; other: ptr t): cint {.
    importc: "json_object_update_new", cdecl, impjanssonHdr.}
proc objectUpdateExistingNew*(`object`: ptr t; other: ptr t): cint {.
    importc: "json_object_update_existing_new", cdecl, impjanssonHdr.}
proc objectUpdateMissingNew*(`object`: ptr t; other: ptr t): cint {.
    importc: "json_object_update_missing_new", cdecl, impjanssonHdr.}
proc arraySize*(array: ptr t): uint {.importc: "json_array_size", cdecl,
                                       impjanssonHdr.}
proc arrayGet*(array: ptr t; index: uint): ptr t {.importc: "json_array_get",
    cdecl, impjanssonHdr.}
proc arraySetNew*(array: ptr t; index: uint; value: ptr t): cint {.
    importc: "json_array_set_new", cdecl, impjanssonHdr.}
proc arrayAppendNew*(array: ptr t; value: ptr t): cint {.
    importc: "json_array_append_new", cdecl, impjanssonHdr.}
proc arrayInsertNew*(array: ptr t; index: uint; value: ptr t): cint {.
    importc: "json_array_insert_new", cdecl, impjanssonHdr.}
proc arrayRemove*(array: ptr t; index: uint): cint {.
    importc: "json_array_remove", cdecl, impjanssonHdr.}
proc arrayClear*(array: ptr t): cint {.importc: "json_array_clear", cdecl,
                                        impjanssonHdr.}
proc arrayExtend*(array: ptr t; other: ptr t): cint {.
    importc: "json_array_extend", cdecl, impjanssonHdr.}
proc arraySet*(array: ptr t; ind: uint; value: ptr t): cint {.
    importc: "json_array_set", cdecl, impjanssonHdr.}
proc arrayAppend*(array: ptr t; value: ptr t): cint {.
    importc: "json_array_append", cdecl, impjanssonHdr.}
proc arrayInsert*(array: ptr t; ind: uint; value: ptr t): cint {.
    importc: "json_array_insert", cdecl, impjanssonHdr.}
proc stringValue*(string: ptr t): cstring {.importc: "json_string_value",
    cdecl, impjanssonHdr.}
proc stringLength*(string: ptr t): uint {.importc: "json_string_length", cdecl,
    impjanssonHdr.}
proc integerValue*(integer: ptr t): clonglong {.importc: "json_integer_value",
    cdecl, impjanssonHdr.}
proc realValue*(real: ptr t): cdouble {.importc: "json_real_value", cdecl,
    impjanssonHdr.}
proc numberValue*(json: ptr t): cdouble {.importc: "json_number_value", cdecl,
    impjanssonHdr.}
proc stringSet*(string: ptr t; value: cstring): cint {.
    importc: "json_string_set", cdecl, impjanssonHdr.}
proc stringSetn*(string: ptr t; value: cstring; len: uint): cint {.
    importc: "json_string_setn", cdecl, impjanssonHdr.}
proc stringSetNocheck*(string: ptr t; value: cstring): cint {.
    importc: "json_string_set_nocheck", cdecl, impjanssonHdr.}
proc stringSetnNocheck*(string: ptr t; value: cstring; len: uint): cint {.
    importc: "json_string_setn_nocheck", cdecl, impjanssonHdr.}
proc integerSet*(integer: ptr t; value: clonglong): cint {.
    importc: "json_integer_set", cdecl, impjanssonHdr.}
proc realSet*(real: ptr t; value: cdouble): cint {.importc: "json_real_set",
    cdecl, impjanssonHdr.}
proc pack*(fmt: cstring): ptr t {.importc: "json_pack", cdecl, impjanssonHdr,
                                  varargs.}
proc packEx*(error: ptr errorT; flags: uint; fmt: cstring): ptr t {.
    importc: "json_pack_ex", cdecl, impjanssonHdr, varargs.}
proc vpackEx*(error: ptr errorT; flags: uint; fmt: cstring;
    ap: vaList): ptr t {.
    importc: "json_vpack_ex", cdecl, impjanssonHdr.}
proc unpack*(root: ptr t; fmt: cstring): cint {.importc: "json_unpack", cdecl,
    impjanssonHdr, varargs.}
proc unpackEx*(root: ptr t; error: ptr errorT; flags: uint;
    fmt: cstring): cint {.
    importc: "json_unpack_ex", cdecl, impjanssonHdr, varargs.}
proc vunpackEx*(root: ptr t; error: ptr errorT; flags: uint; fmt: cstring;
                 ap: vaList): cint {.importc: "json_vunpack_ex", cdecl,
                                      impjanssonHdr.}
proc sprintf*(fmt: cstring): ptr t {.importc: "json_sprintf", cdecl,
                                     impjanssonHdr, varargs.}
proc vsprintf*(fmt: cstring; ap: vaList): ptr t {.importc: "json_vsprintf",
    cdecl, impjanssonHdr.}
proc equalInternal(value1: ptr t; value2: ptr t): cint {.importc: "json_equal", cdecl,
    impjanssonHdr.}
proc equal*(value1: ptr t, value2: ptr t): bool = value1.equalInternal(value2) != 0
proc copy*(value: ptr t): ptr t {.importc: "json_copy", cdecl, impjanssonHdr.}
proc deepCopy*(value: ptr t): ptr t {.importc: "json_deep_copy", cdecl,
                                       impjanssonHdr.}
proc loads*(input: cstring; flags: uint; error: ptr errorT): ptr t {.
    importc: "json_loads", cdecl, impjanssonHdr.}
proc loadb*(buffer: cstring; buflen: uint; flags: uint;
    error: ptr errorT): ptr t {.
    importc: "json_loadb", cdecl, impjanssonHdr.}
proc loadf*(input: File; flags: uint; error: ptr errorT): ptr t {.
    importc: "json_loadf", cdecl, impjanssonHdr.}
proc loadfd*(input: cint; flags: uint; error: ptr errorT): ptr t {.
    importc: "json_loadfd", cdecl, impjanssonHdr.}
proc loadFile*(path: cstring; flags: uint; error: ptr errorT): ptr t {.
    importc: "json_load_file", cdecl, impjanssonHdr.}
proc loadCallback*(callback: loadCallbackT; data: pointer; flags: uint;
                    error: ptr errorT): ptr t {.importc: "json_load_callback",
    cdecl, impjanssonHdr.}
proc dumpsInternal(json: ptr t; flags: uint): cstring {.importc: "json_dumps", cdecl,
    impjanssonHdr.}
proc dumps*(json: ptr t, flags: uint): string =
  let text = json.dumpsInternal(flags)
  result = $text
  c_free(text)
proc dumpb*(json: ptr t; buffer: cstring; size: uint; flags: uint): uint {.
    importc: "json_dumpb", cdecl, impjanssonHdr.}
proc dumpf*(json: ptr t; output: File; flags: uint): cint {.
    importc: "json_dumpf", cdecl, impjanssonHdr.}
proc dumpfd*(json: ptr t; output: cint; flags: uint): cint {.
    importc: "json_dumpfd", cdecl, impjanssonHdr.}
proc dumpFile*(json: ptr t; path: cstring; flags: uint): cint {.
    importc: "json_dump_file", cdecl, impjanssonHdr.}
proc dumpCallback*(json: ptr t; callback: dumpCallbackT; data: pointer;
                    flags: uint): cint {.importc: "json_dump_callback", cdecl,
    impjanssonHdr.}
proc setAllocFuncs*(mallocFn: mallocT; freeFn: freeT) {.
    importc: "json_set_alloc_funcs", cdecl, impjanssonHdr.}
proc getAllocFuncs*(mallocFn: ptr mallocT; freeFn: ptr freeT) {.
    importc: "json_get_alloc_funcs", cdecl, impjanssonHdr.}
proc versionStr*(): cstring {.importc: "jansson_version_str", cdecl,
                               impjanssonHdr.}
proc versionCmp*(major: cint; minor: cint; micro: cint): cint {.
    importc: "jansson_version_cmp", cdecl, impjanssonHdr.}
{.pop.}
