import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

DynamicLibrary? _lib;

// Lazy load (chỉ load khi cần)
DynamicLibrary? _loadLibSafe() {
  if (_lib != null) return _lib;

  try {
    if (Platform.isAndroid) {
      _lib = DynamicLibrary.open("librust_hello.so");
    } else if (Platform.isMacOS) {
      _lib = DynamicLibrary.open("librust_hello.dylib");
    } else if (Platform.isWindows) {
      _lib = DynamicLibrary.open("rust_hello.dll");
    } else if (Platform.isLinux) {
      _lib = DynamicLibrary.open("librust_hello.so");
    } else if (Platform.isIOS) {
      _lib = DynamicLibrary.process();
    }
  } catch (e) {
    print("⚠️ Rust lib load failed: $e");
    _lib = null;
  }

  return _lib;
}

// ===== API =====

String sayHello() {
  final lib = _loadLibSafe();

  // 👉 fallback nếu không load được lib
  if (lib == null) {
    return "Hello (Rust lib not available)";
  }

  try {
    // bind function
    final sayHello = lib
        .lookup<NativeFunction<Pointer<Utf8> Function()>>("say_hello")
        .asFunction<Pointer<Utf8> Function()>();

    final free = lib
        .lookup<NativeFunction<Void Function(Pointer<Utf8>)>>("free_string")
        .asFunction<void Function(Pointer<Utf8>)>();

    final ptr = sayHello();
    final msg = ptr.toDartString();
    free(ptr);

    return msg;
  } catch (e) {
    print("error: $e");
    return "Sayhello from Rustlib error:$e)";
  }
}
