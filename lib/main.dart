
import 'package:Insuralink/repository/AuthenticationRepository.dart';
import 'package:Insuralink/bloc/AuthenticationBloc.dart';
import 'package:Insuralink/repository/UserRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  final authenticationRepository = AuthenticationRepository();
  final userRepository = UserRepository();

  runApp(
    BlocProvider<AuthenticationBloc>(
      create: (context){
        return AuthenticationBloc(authenticationRepository: authenticationRepository, userRepository: userRepository)..add(AppStarted());
      },
      child: App(),
  ));
}

class App extends StatelessWidget {

  const App({
    Key? key,
    required this.authenticationRepository,
    required this.userRepository,
  }) : super(key: key);

  final AuthenticationRepository authenticationRepository;
  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authenticationRepository,
      child: BlocProvider(
        create: (_) => AuthenticationBloc(authenticationRepository: authenticationRepository, userRepository: userRepository,),
        child: AppView(),
      ),
    );
  }
}
