import '../../../../models/user_model.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final AuthResponse authResponse;

  LoginSuccess({required this.authResponse});
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({required this.error});
}
