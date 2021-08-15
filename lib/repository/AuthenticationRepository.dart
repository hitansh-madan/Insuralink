import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/credentials.dart';

class AuthenticationRepository {
  static AuthenticationRepository? _instance;

  factory AuthenticationRepository() =>
      _instance ??= AuthenticationRepository._(FlutterSecureStorage());

  AuthenticationRepository._(this._storage);
  final FlutterSecureStorage _storage;

  Future<void> persistKey(EthPrivateKey privateKey) async {
    await _storage.write(key:'key', value: privateKey.toString());
  }

  Future<bool> hasKey() async {
    var value = await _storage.read(key: 'key');
    return value != null;
  }

  Future<void> deleteKey() async {
    return _storage.delete(key: 'key');
  }

  Future<EthPrivateKey> getKey() async {
    String? keyString = await _storage.read(key: 'key');
    return EthPrivateKey.fromHex(keyString ?? '0');
  }
}
