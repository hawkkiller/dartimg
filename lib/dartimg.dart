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

  malloc.free(bytesPtr);

  final resultRef = result.ref;

  if (!resultRef.is_success) {
    final error = resultRef.error;

    final code = error.error_code;
    final message = error.message.cast<Utf8>().toDartString();

    throw Exception('Error code: $code, message: $message');
  }

  final data = resultRef.success.data;
  final length = resultRef.success.len;

  // Convert the result pointer back to a Uint8List
  final resultList = data.asTypedList(
    length,
    finalizer: _bindings.addresses.deallocate_resize_result.cast(),
    token: result.cast(),
  );

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
