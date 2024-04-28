import 'dart:math';

class RSA {
  late int p, q, n, phi, e, d;

  bool isPrime(int n) {
    if (n <= 1) return false;
    for (int i = 2; i <= sqrt(n); i++) {
      if (n % i == 0) return false;
    }
    return true;
  }

  void generatePQ() {
    List<int> primes = [];
    for (int i = 10; i < 100; i++) {
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
    List<int> ciphertext = [];
    for (int i = 0; i < plaintext.length; i++) {
      int result = 1;
      for (int j = 0; j < e; j++) {
        result = (result * plaintext.codeUnitAt(i)) % n;
      }
      ciphertext.add(result);
    }
    return ciphertext;
  }

  String decryptLine(List<int> ciphertext) {
    String plaintext = '';
    for (int i = 0; i < ciphertext.length; i++) {
      int result = 1;
      for (int j = 0; j < d; j++) {
        result = (result * ciphertext[i]) % n;
      }
      plaintext += String.fromCharCode(result);
    }
    return plaintext;
  }
}