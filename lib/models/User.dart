
import 'package:equatable/equatable.dart';
import 'package:web3dart/credentials.dart';

enum Genders { M, F, NB }

class User extends Equatable {
  User({
    String? firstName,
    String? lastName,
    Genders? gender,
    int? dob,
    EthereumAddress? address,
    EthPrivateKey? privateKey
  })  : firstName = firstName ?? "",
        lastName = lastName ?? "",
        gender = gender ?? Genders.M,
        dob = dob ?? 0,
        address = address ?? EthereumAddress.fromHex(""),
        privateKey = privateKey ?? EthPrivateKey.fromHex("");

  final String firstName;
  final String lastName;
  final Genders gender;
  final int dob;
  final EthereumAddress address;
  final EthPrivateKey privateKey;

  @override
  List<Object> get props => [firstName, lastName, gender, dob, address, privateKey];
}
