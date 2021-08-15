import 'dart:async';
import 'package:Insuralink/repository/AuthenticationRepository.dart';
import 'package:Insuralink/models/User.dart';
import 'package:Insuralink/repository/UserRepository.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:web3dart/credentials.dart';


enum AuthenticationStatus { unknown, authenticated, unauthenticated }

abstract class AuthenticationEvent extends Equatable {
  AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}
class LoggedIn extends AuthenticationEvent {
  LoggedIn(this.privateKey , this.user);
  final EthPrivateKey privateKey;
  final User user;
}
class LoggedOut extends AuthenticationEvent {}


class AuthenticationState extends Equatable {
  AuthenticationState._({
    this.status = AuthenticationStatus.unknown
  });

  AuthenticationState.unknown() : this._();

  AuthenticationState.authenticated()
      : this._(status: AuthenticationStatus.authenticated);

  AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  final AuthenticationStatus status;

  @override
  List<Object> get props => [status];
}

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({required this.authenticationRepository , required this.userRepository}):super(AuthenticationState.unknown());

  final AuthenticationRepository authenticationRepository;
  final UserRepository userRepository ;

  @override
  Stream<AuthenticationState> mapEventToState(AuthenticationEvent event) async* {
    if (event is AppStarted) {
      yield* _appStarted();
    } else if (event is LoggedIn) {
      yield*_loggedIn(event);
    } else if (event is LoggedOut){
      yield* _loggedOut();
    }
  }

  Stream<AuthenticationState> _appStarted() async* {
    final hasKey = await authenticationRepository.hasKey();

    if (!hasKey) {
      yield AuthenticationState.unauthenticated();
      return;
    }
    yield AuthenticationState.authenticated();
  }

  Stream<AuthenticationState> _loggedIn(LoggedIn event) async* {
   // yield AuthenticationLoading();
    await authenticationRepository.persistKey(event.privateKey);
    userRepository.user = event.user;
    yield* _appStarted();
  }

  Stream<AuthenticationState> _loggedOut() async* {
   // yield AuthenticationLoggingOut();
    await authenticationRepository.deleteKey();
    yield* _appStarted();
  }
}
