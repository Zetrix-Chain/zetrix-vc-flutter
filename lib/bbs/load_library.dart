import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart' as p;

DynamicLibrary loadBbsLib() {
  if (Platform.isAndroid) {
    return DynamicLibrary.open("libbbs.so");
  } else if (Platform.isWindows) {
    final exeDir = Directory.current.path;
    final dllPath =
        p.join(exeDir, 'build', 'windows', 'x64', 'debug', 'bundle', 'bbs.dll');
    return DynamicLibrary.open(dllPath);
    // return DynamicLibrary.open('bbs.dll');
  } else if (Platform.isMacOS) {
    return DynamicLibrary.open('libbbs.dylib');
  } else if (Platform.isLinux) {
    return DynamicLibrary.open('libbbs.so');
  }
  print("📁 Directory.current = ${Directory.current.path}");
  throw UnsupportedError('Unsupported platform');
}
