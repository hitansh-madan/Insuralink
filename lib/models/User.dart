
import 'package:equatable/equatable.dart';
import 'package:web3dart/credentials.dart';

// either handle policies inside the user object and make a factory constructor
// or handle them outside the user object // preferable


enum Genders { M, F, NB }
// create a policy model that is used to display policy pages and widgets
// policy details page is wrapped in a policyBloc
// make a function that creates user from userService response;
class User extends Equatable {
  User({
    String? firstName,
    String? lastName,
    Genders? gender,
    int? age,
    EthPrivateKey? privateKey,
  })  : firstName = firstName ?? "",
        lastName = lastName ?? "",
        gender = gender ?? Genders.M,
        age = age ?? 0,
        privateKey = privateKey ?? EthPrivateKey.fromHex("");

  final String firstName;
  final String lastName;
  final int age;
  final Genders gender;
  final EthPrivateKey privateKey;

  @override
  List<Object> get props => [firstName, lastName, gender, age, privateKey];

  factory User.fromResponse(List<dynamic> response , EthPrivateKey privateKey){
    List<Genders> genders = Genders.values;
    return User(
      firstName: response[0],
      lastName: response[1],
      age: response[2],
      gender: genders[response[3]],
      privateKey: privateKey
    );
  }
}
