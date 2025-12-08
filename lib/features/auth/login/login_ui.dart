import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../signup/signup_ui.dart';
import '../../../../core/services/auth_service.dart';
import 'login_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

class RovioLoginScreen extends StatefulWidget {
  final VoidCallback? onToggleAuthMode;
  final VoidCallback? onLoginSuccess;

  const RovioLoginScreen({Key? key, this.onToggleAuthMode, this.onLoginSuccess})
    : super(key: key);

  @override
  _RovioLoginScreenState createState() => _RovioLoginScreenState();
}

class _RovioLoginScreenState extends State<RovioLoginScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = 'masroorrehan786@gmail.com';
  }

  void _handleLogin(BuildContext context) {
    // Validate form
    if (_emailController.text.isEmpty) {
      _showSnackBar('Please enter your email');
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      _showSnackBar('Please enter a valid email');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showSnackBar('Please enter your password');
      return;
    }

    // Trigger login through LoginBloc
    context.read<LoginBloc>().add(
      LoginButtonPressed(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleAuthError(String errorMessage) {
    String userFriendlyMessage;

    if (errorMessage.contains('Connection refused') ||
        errorMessage.contains('SocketException')) {
      userFriendlyMessage =
          'Unable to connect to server. Please check your internet connection and try again.';
    } else if (errorMessage.contains('timeout')) {
      userFriendlyMessage =
          'Request timed out. Please check your internet connection and try again.';
    } else if (errorMessage.contains('Invalid credentials') ||
        errorMessage.contains('Wrong password') ||
        errorMessage.contains('User not found')) {
      userFriendlyMessage =
          'Invalid email or password. Please check your credentials and try again.';
    } else if (errorMessage.contains('Account not verified')) {
      userFriendlyMessage =
          'Please verify your email address before logging in.';
    } else if (errorMessage.contains('Account locked') ||
        errorMessage.contains('Too many attempts')) {
      userFriendlyMessage =
          'Account temporarily locked. Please try again later.';
    } else {
      userFriendlyMessage = 'Login failed. Please try again.';
    }

    _showSnackBar(userFriendlyMessage);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          // Login successful
          _showSuccessSnackBar('Login successful! Welcome back!');
          // Call the success callback to trigger navigation
          widget.onLoginSuccess?.call();
        } else if (state is LoginFailure) {
          // Login failed
          _handleAuthError(state.error);
        }
      },
      child: Builder(
        builder: (context) => Scaffold(
          resizeToAvoidBottomInset:
              false, // Prevent keyboard from pushing UI up
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFFFFF), // White at the top
                  Color(0xFFF8F1D4), // Honey bee yellow in the middle
                  Color(0xFFFDFCF7), // Creamy white at the bottom
                ],
                stops: [0.0, 0.5, 1.0], // Yellow is in the middle
              ),
            ),

            child: SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 60.h),

                      // Welcome Back to Rovio title
                      Text(
                        'Welcome Back\nto WearSmart',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),

                      SizedBox(height: 50.h),

                      // Email field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'E-mail',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.r),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1.w,
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 16.h,
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16.sp,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // Password field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.r),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1.w,
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 16.h,
                                ),
                                hintText: '••••••••••••',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16.sp,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey[600],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Handle forgot password
                          },
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Log in button
                      Container(
                        width: double.infinity,
                        height: 56.h,
                        child: BlocBuilder<LoginBloc, LoginState>(
                          builder: (context, state) {
                            bool isLoading = state is LoginLoading;
                            return ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      _handleLogin(context);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28.r),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      height: 20.h,
                                      width: 20.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      'Log in',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 40.h),

                      // Fashion illustration image - full width
                      Container(
                        height: 150.h,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: Image.asset(
                            'assets/images/try2.png',
                            width: double.infinity,
                            height: 200.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Sign up text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New to Rovio? ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Handle sign up
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: InkWell(
                              onTap: () {
                                if (widget.onToggleAuthMode != null) {
                                  widget.onToggleAuthMode!();
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SmartWearRegisterScreen(),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Usage in main.dart:
/*
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rovio Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RovioLoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
*/
