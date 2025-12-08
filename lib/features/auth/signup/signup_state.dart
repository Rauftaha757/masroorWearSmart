import '../../../../models/user_model.dart';

abstract class SignupState {}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class SignupSuccess extends SignupState {
  final AuthResponse authResponse;

  SignupSuccess({required this.authResponse});
}

class SignupFailure extends SignupState {
  final String error;

  SignupFailure({required this.error});
}
