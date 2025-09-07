import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'package:dartimg/src/dartimg_bindings.dart';
import 'package:ffi/ffi.dart';

Uint8List upscaleImage({
  required Uint8List image,
  required String inputImageFormat,
  required String outputImageFormat,
  double upscaleFactor = 2,
}) {
  final bytesPtr = uint8ListToPointer(image);
  final bytesLen = image.lengthInBytes;
  final inputFormat = stringToPointer(inputImageFormat);
  final outputFormat = stringToPointer(outputImageFormat);

  final result = _bindings.upscale_image_from_bytes(
    bytesPtr,
    bytesLen,
    upscaleFactor,
    inputFormat,
    outputFormat,
  );

  malloc.free(bytesPtr);
  malloc.free(inputFormat);
  malloc.free(outputFormat);

  final resultRef = result.ref;

  if (!resultRef.is_success) {
    final error = resultRef.error;

    final code = error.error_code;
    final message = error.message.cast<Utf8>().toDartString();

    _bindings.deallocate_resize_result(result);

    throw Exception('Error code: $code, message: $message');
  }

  final data = resultRef.success.data;
  final length = resultRef.success.len;

  // Convert the result pointer back to a Uint8List
  final resultList = Uint8List.fromList(data.asTypedList(length));
  _bindings.deallocate_resize_result(result);

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

ffi.Pointer<ffi.Uint8> stringToPointer(String str) {
  final units = utf8.encode(str);
  final ptr = malloc<ffi.Uint8>(units.length + 1);
  final nativeString = ptr.asTypedList(units.length + 1);
  nativeString.setAll(0, units);
  nativeString[units.length] = 0; // Null-terminate the string
  return ptr;
}
