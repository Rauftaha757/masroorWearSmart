import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/auth_service.dart';
import '../auth/auth_bloc.dart';
import '../../core/widgets/BottomNavigationBar/ButtomNavigationBar.dart';
import 'auth_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AuthBloc(authService: AuthService())..add(AuthInitialized()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is AuthAuthenticated) {
            return CarouselNavUploadScreen();
          } else if (state is AuthUnauthenticated) {
            // Show authentication screen (login/signup)
            return const AuthScreen();
          } else if (state is AuthError) {
            // Show auth screen and let individual screens handle errors
            return const AuthScreen();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
