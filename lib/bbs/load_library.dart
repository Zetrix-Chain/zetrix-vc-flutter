import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:zetrix_vc_flutter/src/utils/tools.dart';

/// Loads the appropriate `DynamicLibrary` for the BBS cryptographic library (`libbbs`),
/// based on the current platform.
///
/// The `loadBbsLib` function identifies the operating system at runtime and dynamically loads
/// the corresponding native library file required for BBS+ cryptographic operations. This ensures
/// compatibility with platforms like Android, Windows, macOS, and Linux, each of which has its own
/// specific library format:

DynamicLibrary loadBbsLib() {
  if (Platform.isAndroid) {
    // Load the Android shared library.
    return DynamicLibrary.open("libbbs.so");
  } else if (Platform.isWindows) {
    // Load the Windows DLL from the debug or build path.
    final exeDir = Directory.current.path;
    final dllPath =
        p.join(exeDir, 'build', 'windows', 'x64', 'debug', 'bundle', 'bbs.dll');
    return DynamicLibrary.open(dllPath);
    // Alternate loading path for general cases (commented out in current code).
    // return DynamicLibrary.open('bbs.dll');
  } else if (Platform.isMacOS) {
    // Load the macOS dynamic library.
    return DynamicLibrary.open('libbbs.dylib');
  } else if (Platform.isLinux) {
    // Load the Linux shared library.
    return DynamicLibrary.open('libbbs.so');
  }
  Tools.logDebug("📁 Directory.current = ${Directory.current.path}");
  throw UnsupportedError('Unsupported platform');
}
