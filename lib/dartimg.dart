import 'dart:ffi' as ffi;

// import 'package:ffi/ffi.dart';
import 'dart:typed_data';

import 'package:dartimg/src/dartimg_bindings.dart';
import 'package:ffi/ffi.dart';

Uint8List upscaleImage(Uint8List image, int upscaleFactor) {
  final bytesPtr = uint8ListToPointer(image);
  final bytesLen = image.lengthInBytes;

  final result = _bindings.upscale_image_from_bytes(bytesPtr, bytesLen, upscaleFactor);
  final resultPtr = result.data;
  final resultLen = result.len;
  final resultError = result.message.cast<Utf8>().toDartString();

  // Convert the result pointer back to a Uint8List
  final resultList = Uint8List.fromList(resultPtr.asTypedList(resultLen));
  // Free the allocated memory
  malloc.free(bytesPtr);

  // Free the image buffer in C
  _bindings.free_image_buffer(resultPtr, resultLen);

  // Free the result pointer
  malloc.free(resultPtr);
  return resultList;
}

int sum(int a, int b) => _bindings.sum(a, b);

const _libname = 'dartimg';
final _dylib = ffi.DynamicLibrary.open('$_libname.framework/$_libname');
final _bindings = DartimgBindings(_dylib);

ffi.Pointer<ffi.Uint8> uint8ListToPointer(Uint8List data) {
  // Allocate native memory
  final ptr = malloc<ffi.Uint8>(data.length);

  // Copy data from Uint8List to allocated memory
  final nativeBytes = ptr.asTypedList(data.length);
  nativeBytes.setAll(0, data);

  return ptr;
}
