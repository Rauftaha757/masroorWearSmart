import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../models/user_model.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthService _authService;

  SignupBloc({required AuthService authService})
    : _authService = authService,
      super(SignupInitial()) {
    on<SignupButtonPressed>(_onSignupButtonPressed);
  }

  Future<void> _onSignupButtonPressed(
    SignupButtonPressed event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading());

    try {
      final registerRequest = RegisterRequest(
        name: event.name,
        email: event.email,
        password: event.password,
        phone: event.phone,
        gender: event.gender,
      );

      final authResponse = await _authService.register(registerRequest);
      emit(SignupSuccess(authResponse: authResponse));
    } catch (error) {
      emit(SignupFailure(error: error.toString()));
    }
  }
}
