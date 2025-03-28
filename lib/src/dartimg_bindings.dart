// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

/// Bindings for `native/out/dartimg.h`.
///
/// Regenerate bindings with `dart run ffigen --config ffigen.yaml`.
///
class DartimgBindings {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  DartimgBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  DartimgBindings.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  int sum(
    int a,
    int b,
  ) {
    return _sum(
      a,
      b,
    );
  }

  late final _sumPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32, ffi.Int32)>>(
          'sum');
  late final _sum = _sumPtr.asFunction<int Function(int, int)>();

  /// Receives compressed image bytes (e.g. PNG, JPG),
  /// resizes it with Lanczos3 (default algorithm), returns raw RGBA buffer.
  ResizeResult upscale_image_from_bytes(
    ffi.Pointer<ffi.Uint8> bytes_ptr,
    int bytes_len,
    double upscale_factor,
  ) {
    return _upscale_image_from_bytes(
      bytes_ptr,
      bytes_len,
      upscale_factor,
    );
  }

  late final _upscale_image_from_bytesPtr = _lookup<
      ffi.NativeFunction<
          ResizeResult Function(ffi.Pointer<ffi.Uint8>, ffi.UintPtr,
              ffi.Float)>>('upscale_image_from_bytes');
  late final _upscale_image_from_bytes = _upscale_image_from_bytesPtr
      .asFunction<ResizeResult Function(ffi.Pointer<ffi.Uint8>, int, double)>();

  void deallocate_buffer(
    ffi.Pointer<ffi.Uint8> ptr,
    int len,
  ) {
    return _deallocate_buffer(
      ptr,
      len,
    );
  }

  late final _deallocate_bufferPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Pointer<ffi.Uint8>, ffi.UintPtr)>>('deallocate_buffer');
  late final _deallocate_buffer = _deallocate_bufferPtr
      .asFunction<void Function(ffi.Pointer<ffi.Uint8>, int)>();
}

final class ResizeSuccess extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> data;

  @ffi.UintPtr()
  external int len;
}

final class ResizeError extends ffi.Struct {
  @ffi.Int32()
  external int error_code;

  external ffi.Pointer<ffi.Uint8> message;
}

final class ResizeResult extends ffi.Struct {
  external ResizeSuccess success;

  external ResizeError error;

  @ffi.Bool()
  external bool is_success;
}
