import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/auth_service.dart';
import 'login/login_ui.dart';
import 'login/login_bloc.dart';
import 'signup/signup_ui.dart';
import 'signup/signup_bloc.dart';
import '../auth/auth_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(authService: AuthService()),
        ),
        BlocProvider<SignupBloc>(
          create: (context) => SignupBloc(authService: AuthService()),
        ),
      ],
      child: Scaffold(
        body: _isLogin
            ? RovioLoginScreen(
                onToggleAuthMode: _toggleAuthMode,
                onLoginSuccess: () {
                  // Trigger AuthBloc to check authentication status
                  context.read<AuthBloc>().add(AuthInitialized());
                },
              )
            : SmartWearRegisterScreen(
                onToggleAuthMode: _toggleAuthMode,
                onSignupSuccess: () {
                  // Trigger AuthBloc to check authentication status
                  context.read<AuthBloc>().add(AuthInitialized());
                },
              ),
      ),
    );
  }
}
