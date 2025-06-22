import 'dart:math';
import 'dart:typed_data';

class GeneratorUtils {
  // Utility for random nonce
  Uint8List generateRandomNonce(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
        List.generate(length, (_) => random.nextInt(256)));
  }
}
