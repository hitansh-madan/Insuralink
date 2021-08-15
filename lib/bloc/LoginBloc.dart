import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web3dart/credentials.dart';
import 'AuthenticationBloc.dart';
import 'package:Insuralink/UserService.dart';

enum LogInStatus { unknown, loggedIn, notLoggedIn }

abstract class LogInEvent extends Equatable {
  LogInEvent();

  @override
  List<Object> get props => [];
}

class LogInButtonPressed extends LogInEvent {
  LogInButtonPressed(this.privateKey);
  final EthPrivateKey privateKey;
}

class LogInState extends Equatable {
  LogInState._({
    this.status = LogInStatus.unknown
  });

  LogInState.unknown() : this._();

  LogInState.loggedIn()
      : this._(status: LogInStatus.loggedIn);

  LogInState.notLoggedIn()
      : this._(status: LogInStatus.notLoggedIn);

  final LogInStatus status;

  @override
  List<Object> get props => [status];
}



class LogInBloc extends Bloc<LogInEvent, LogInState> {
  final AuthenticationBloc authenticationBloc;

  LogInBloc({required this.authenticationBloc}) : super(LogInState.unknown());

  @override
  Stream<LogInState> mapEventToState(LogInEvent event) async* {
    if (event is LogInButtonPressed) {
      //yield LogInLoading();
      final request = LogInRequest(event.email, event.password);

      try {
        final response = await UserService().login(request);
        authenticationBloc.add(LoggedIn(response.jwt, response.email));
      } on UnauthorizedException {
        yield SignInFailure('Invalid email or password. Please try again.');
      } catch (error) {
        yield SignInFailure(error.toString());
      }
    }
  }
}





