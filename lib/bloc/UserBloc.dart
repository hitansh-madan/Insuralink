import 'dart:async';
import 'package:Insuralink/UserService.dart';
import 'package:Insuralink/bloc/AuthenticationBloc.dart';
import 'package:Insuralink/models/User.dart';
import 'package:Insuralink/repository/UserRepository.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:web3dart/credentials.dart';


enum UserStatus { unknown, initialized, uninitialized }

abstract class UserEvent extends Equatable {
  UserEvent();

  @override
  List<Object> get props => [];
}

class LogIn extends UserEvent {
  LogIn(this.privateKey);
  final EthPrivateKey privateKey;
}

class Refreshed extends UserEvent {}

class UserState extends Equatable {
  UserState._({
    this.status = UserStatus.unknown
  });

  UserState.unknown() : this._();

  UserState.initialized()
      : this._(status: UserStatus.initialized);

  UserState.uninitialized()
      : this._(status: UserStatus.uninitialized);

  final UserStatus status;

  @override
  List<Object> get props => [status];
}

class UserBloc extends Bloc<UserEvent, UserState> {

  UserBloc({required this.authenticationBloc ,required this.userRepository}):super(UserState.unknown());

  final UserRepository userRepository ;
  final AuthenticationBloc authenticationBloc;


  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    if (event is LogIn) {
      yield* _logIn(event);
    } else if (event is Refreshed) {
      yield* _refreshed();
    }
  }

  Future<User> _getUser(EthPrivateKey privateKey) async{
    var userService = await UserService.init(privateKey);
    return User.fromResponse(await userService.getCustomer(),privateKey);
  }

  Stream<UserState> _userState() async* {
    final hasUser = userRepository.hasUser();

    if (!hasUser) {
      yield UserState.uninitialized();
    }
    yield UserState.initialized();
  }

  Stream<UserState> _logIn(LogIn event) async* {
    yield* _userState();
  }

  Stream<UserState> _refreshed() async* {
    // yield AuthenticationLoading();
    var _privateKey = await authenticationBloc.authenticationRepository.getKey();
    User _user = await _getUser(_privateKey);
    userRepository.user = _user;
    yield* _userState();
  }
}
