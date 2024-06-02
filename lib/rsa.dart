import 'dart:math';
import 'dart:convert';
import 'dart:io';

class RSA {
  late int p, q, n, phi, e, d;

  int _keySafetyLevel = 0; // 기본 값

  void setKeySafetyLevel(int level) {
    _keySafetyLevel = level;
  }

  bool isPrime(int n) {
    if (n <= 1) return false;
    for (int i = 2; i <= sqrt(n); i++) {
      if (n % i == 0) return false;
    }
    return true;
  }

  void generatePQ() {
    List<int> primes = [];
    for (int i = 10; i < _keySafetyLevel; i++) {
      if (isPrime(i)) primes.add(i);
    }
    p = primes[Random().nextInt(primes.length)];
    q = primes[Random().nextInt(primes.length)];
  }

  int gcd(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  void generatePublicKey() {
    n = p * q;
    phi = (p - 1) * (q - 1);
    for (int i = 2; i < phi; i++) {
      if (gcd(phi, i) == 1) {
        e = i;
        break;
      }
    }
  }

  void generatePrivateKey() {
    d = 1;
    while ((e * d) % phi != 1 || d == e && (e * d <= phi)) {
      d++;
    }
  }

  List<int> encryptLine(String plaintext) {
    List<int> plaintextBytes = utf8.encode(plaintext); // 텍스트를 UTF-8 바이트로 인코딩
    List<int> ciphertext = [];
    for (int byte in plaintextBytes) {
      int result = 1;
      for (int j = 0; j < e; j++) {
        result = (result * byte) % n;
      }
      ciphertext.add(result);
    }
    return ciphertext;
  }

  String decryptLine(List<int> ciphertext) {
    List<int> decryptedBytes = [];
    for (int encryptedByte in ciphertext) {
      int result = 1;
      for (int j = 0; j < d; j++) {
        result = (result * encryptedByte) % n;
      }
      decryptedBytes.add(result);
    }
    return utf8.decode(decryptedBytes);
  }

  // 키를 텍스트 파일로 변환하는 메서드
  String toKeyString() {
    return jsonEncode({
      'p': p,
      'q': q,
      'n': n,
      'phi': phi,
      'e': e,
      'd': d,
    });
  }

  // 텍스트 파일에서 키를 복원하는 메서드
  void fromKeyString(String keyString) {
    Map<String, dynamic> keyMap = jsonDecode(keyString);
    p = keyMap['p'];
    q = keyMap['q'];
    n = keyMap['n'];
    phi = keyMap['phi'];
    e = keyMap['e'];
    d = keyMap['d'];
  }

  // 파일에서 키를 로드하는 메서드
  Future<void> loadKeysFromFile(String filePath) async {
    try {
      final keyFile = File(filePath);
      String keyString = await keyFile.readAsString();
      fromKeyString(keyString);
    } catch (e) {
      print('키 파일을 로드하는 도중 오류가 발생했습니다: $e');
    }
  }
}