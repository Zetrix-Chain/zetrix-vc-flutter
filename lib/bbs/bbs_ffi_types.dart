import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

base class ByteArray extends Struct {
  @Uint64()
  external int length;

  external Pointer<Uint8> data;

  static ByteArray fromUint8List(Uint8List list) {
    final bytePtr = calloc<Uint8>(list.length);
    // final byteList = bytePtr.asTypedList(list.length)..setAll(0, list);

    final arrayPtr = calloc<ByteArray>();
    arrayPtr.ref
      ..length = list.length
      ..data = bytePtr;

    return arrayPtr.ref;
  }
}

base class ByteBuffer extends Struct {
  @Int64()
  external int len;

  external Pointer<Uint8> data;

  Uint8List toUint8List() {
    return data.asTypedList(len);
  }
}

base class ExternError extends Struct {
  @Int32()
  external int code;

  external Pointer<Utf8> message;
}

extension ByteArrayHelper on ByteArray {
  static Pointer<ByteArray> allocate(Uint8List list) {
    final ptr = calloc<ByteArray>();
    final dataPtr = calloc<Uint8>(list.length);
    for (var i = 0; i < list.length; i++) {
      dataPtr[i] = list[i];
    }
    ptr.ref.data = dataPtr;
    ptr.ref.length = list.length;
    return ptr;
  }
}
