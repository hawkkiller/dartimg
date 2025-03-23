import 'dart:ffi';

import 'package:dartimg/src/dartimg_bindings.dart';

int sum(int a, int b) => _bindings.sum(a, b);

const _libname = 'dartimg';
final _dylib = DynamicLibrary.open('$_libname.framework/$_libname');
final _bindings = DartimgBindings(_dylib);