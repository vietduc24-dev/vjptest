import 'dart:convert';

import 'package:crypto/crypto.dart';

String hashPassword(String password) {
  var bytes = utf8.encode(password); // Convert password to utf8 bytes
  var digest = sha256.convert(bytes); // Hash using SHA-256

  return digest.toString(); // Convert hash to a string
}
