import 'dart:math';
import 'dart:typed_data';

/// A utility class for generating cryptographic elements, such as random nonces.
class GeneratorUtils {
  /// Generates a cryptographically secure random nonce of the specified [length].
  ///
  /// - Uses `Random.secure()` to ensure high-quality randomness suitable for cryptographic use.
  /// - Returns a [Uint8List] containing the generated random bytes.
  Uint8List generateRandomNonce(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
        List.generate(length, (_) => random.nextInt(256)));
  }
}
