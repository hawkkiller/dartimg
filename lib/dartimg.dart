import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'package:dartimg/src/dartimg_bindings.dart';
import 'package:ffi/ffi.dart';

Uint8List upscaleImage(Uint8List image, double upscaleFactor) {
  final bytesPtr = uint8ListToPointer(image);
  final bytesLen = image.lengthInBytes;

  final result = _bindings.upscale_image_from_bytes(
    bytesPtr,
    bytesLen,
    upscaleFactor,
  );

  if (!result.is_success) {
    final error = result.error;

    final code = error.error_code;
    final message = error.message.cast<Utf8>().toDartString();

    // Free the error message pointer
    malloc.free(error.message);

    throw Exception('Error code: $code, message: $message');
  }

  final data = result.success.data;
  final length = result.success.len;

  // Convert the result pointer back to a Uint8List
  final resultList = Uint8List.fromList(data.asTypedList(length));

  malloc.free(bytesPtr);

  _bindings.deallocate_buffer(data, bytesLen);

  return resultList;
}

int sum(int a, int b) => _bindings.sum(a, b);

final _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return ffi.DynamicLibrary.process();
  } else if (Platform.isWindows) {
    return ffi.DynamicLibrary.open('image_upscale.dll');
  } else {
    throw UnsupportedError('Unsupported platform');
  }
}();

final _bindings = DartimgBindings(_dylib);

ffi.Pointer<ffi.Uint8> uint8ListToPointer(Uint8List data) {
  // Allocate native memory
  final ptr = malloc<ffi.Uint8>(data.length);

  // Copy data from Uint8List to allocated memory
  final nativeBytes = ptr.asTypedList(data.length);
  nativeBytes.setAll(0, data);

  return ptr;
}
