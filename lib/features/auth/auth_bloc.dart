import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';
import '../../core/services/auth_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthInitialized extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String? phone;
  final String? gender;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
    this.gender,
  });

  @override
  List<Object?> get props => [email, password, name, phone, gender];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthTokenRefreshRequested extends AuthEvent {}

class AuthProfileUpdateRequested extends AuthEvent {
  final String? name;
  final String? phone;
  final String? gender;

  const AuthProfileUpdateRequested({this.name, this.phone, this.gender});

  @override
  List<Object?> get props => [name, phone, gender];
}

class AuthPasswordChangeRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const AuthPasswordChangeRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}

class AuthAvatarUploadRequested extends AuthEvent {
  final String imagePath;

  const AuthAvatarUploadRequested({required this.imagePath});

  @override
  List<Object> get props => [imagePath];
}

class AuthAccountDeleteRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthSuccess extends AuthState {
  final String message;

  const AuthSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
    : _authService = authService,
      super(AuthInitial()) {
    on<AuthInitialized>(_onInitialized);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthTokenRefreshRequested>(_onTokenRefreshRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
    on<AuthPasswordChangeRequested>(_onPasswordChangeRequested);
    on<AuthAvatarUploadRequested>(_onAvatarUploadRequested);
    on<AuthAccountDeleteRequested>(_onAccountDeleteRequested);
  }

  Future<void> _onInitialized(
    AuthInitialized event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.loadUserFromStorage();
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        final user = _authService.currentUser;
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'Initialization failed: $e'));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final loginRequest = LoginRequest(
        email: event.email,
        password: event.password,
      );

      final authResponse = await _authService.login(loginRequest);
      emit(AuthAuthenticated(user: authResponse.user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final registerRequest = RegisterRequest(
        email: event.email,
        password: event.password,
        name: event.name,
        phone: event.phone,
        gender: event.gender,
      );

      final authResponse = await _authService.register(registerRequest);
      emit(AuthAuthenticated(user: authResponse.user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onTokenRefreshRequested(
    AuthTokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final authResponse = await _authService.refreshToken();
      if (authResponse != null) {
        emit(AuthAuthenticated(user: authResponse.user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final updateRequest = UpdateProfileRequest(
        name: event.name,
        phone: event.phone,
        gender: event.gender,
      );

      final user = await _authService.updateProfile(updateRequest);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onPasswordChangeRequested(
    AuthPasswordChangeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final changePasswordRequest = ChangePasswordRequest(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );

      await _authService.changePassword(changePasswordRequest);
      emit(AuthSuccess(message: 'Password changed successfully'));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAvatarUploadRequested(
    AuthAvatarUploadRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authService.uploadAvatar(event.imagePath);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAccountDeleteRequested(
    AuthAccountDeleteRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.deleteAccount();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
