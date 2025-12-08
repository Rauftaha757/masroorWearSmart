import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../models/user_model.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService _authService;

  LoginBloc({required AuthService authService})
    : _authService = authService,
      super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  Future<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      final loginRequest = LoginRequest(
        email: event.email,
        password: event.password,
      );

      final authResponse = await _authService.login(loginRequest);
      emit(LoginSuccess(authResponse: authResponse));
    } catch (error) {
      emit(LoginFailure(error: error.toString()));
    }
  }
}
