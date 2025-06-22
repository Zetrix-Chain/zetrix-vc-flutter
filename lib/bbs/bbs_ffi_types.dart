import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

/// Represents a byte array with a length and a data pointer for FFI (Foreign Function Interface) purposes.
///
/// The [ByteArray] class is used to seamlessly pass `Uint8List` data between Dart and native code.
/// It ensures that the data is properly allocated in memory and can be passed to native libraries.
base class ByteArray extends Struct {
  /// The number of bytes in the ByteArray.
  @Uint64()
  external int length;

  /// A pointer to the unsigned 8-bit integer data.
  external Pointer<Uint8> data;

  /// Creates a new [ByteArray] from a [Uint8List].
  ///
  /// This method allocates memory for the given `Uint8List`, sets the data pointer,
  /// and assigns the length appropriately.
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

/// Represents a byte buffer, used for converting raw data between native and Dart.
///
/// The [ByteBuffer] class is similar to [ByteArray], with specific focus on converting the
/// raw pointer-based data into a Dart-native `Uint8List` for easier manipulation.
base class ByteBuffer extends Struct {
  /// The number of bytes in the buffer.
  @Int64()
  external int len;

  /// A pointer to the raw unsigned 8-bit integer data.
  external Pointer<Uint8> data;

  /// Converts the byte buffer's data into a `Uint8List`.
  ///
  /// This method provides a Dart-friendly representation of the raw native buffer data.
  Uint8List toUint8List() {
    return data.asTypedList(len);
  }
}

/// Represents an external error structure for FFI operations.
///
/// The [ExternError] class is used to encapsulate errors returned by native libraries, allowing Dart
/// to retrieve the error code and message.
base class ExternError extends Struct {
  /// The error code returned by the native library.
  @Int32()
  external int code;

  /// A nullable pointer to the error message, UTF-8 encoded.
  external Pointer<Utf8> message;
}

/// An extension to simplify memory allocation and data conversion for [ByteArray].
///
/// The `ByteArrayHelper` extension provides utilities to allocate memory for a [ByteArray]
/// and assign it a `Uint8List`.
extension ByteArrayHelper on ByteArray {
  /// Allocates memory for a [ByteArray] and initializes it with the given [Uint8List].
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
