import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'config.dart';

List<int> _deriveKey(String secret) {
  final digest = sha256.convert(utf8.encode(secret)).bytes;
  return digest;
}

List<int> drmXor(List<int> data) {
  final key = _deriveKey(AppConfig.drmSecret);
  final out = List<int>.filled(data.length, 0);
  for (var i = 0; i < data.length; i++) {
    out[i] = data[i] ^ key[i % key.length];
  }
  return out;
}
