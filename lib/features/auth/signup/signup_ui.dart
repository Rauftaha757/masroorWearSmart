import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../login/login_ui.dart';
import '../../../../core/services/auth_service.dart';
import 'signup_bloc.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SmartWearRegisterScreen extends StatefulWidget {
  final VoidCallback? onToggleAuthMode;
  final VoidCallback? onSignupSuccess;

  const SmartWearRegisterScreen({
    Key? key,
    this.onToggleAuthMode,
    this.onSignupSuccess,
  }) : super(key: key);

  @override
  _SmartWearRegisterScreenState createState() =>
      _SmartWearRegisterScreenState();
}

class _SmartWearRegisterScreenState extends State<SmartWearRegisterScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = 'masroorrehan786@gmail.com';
  }

  void _handleRegister(BuildContext context) {
    // Validate form
    if (_nameController.text.isEmpty) {
      _showSnackBar('Please enter your name');
      return;
    }

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

    if (_passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters');
      return;
    }

    // Trigger registration through SignupBloc
    context.read<SignupBloc>().add(
      SignupButtonPressed(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        // Don't send phone and gender since they're optional
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
    } else if (errorMessage.contains('Email already exists') ||
        errorMessage.contains('User already exists')) {
      userFriendlyMessage =
          'An account with this email already exists. Please try logging in instead.';
    } else if (errorMessage.contains('Invalid email')) {
      userFriendlyMessage = 'Please enter a valid email address.';
    } else if (errorMessage.contains('Password too weak')) {
      userFriendlyMessage =
          'Password is too weak. Please choose a stronger password.';
    } else {
      userFriendlyMessage = 'Registration failed. Please try again.';
    }

    _showSnackBar(userFriendlyMessage);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        if (state is SignupSuccess) {
          // Registration successful
          _showSuccessSnackBar('Registration successful! Welcome!');
          // Call the success callback to trigger navigation
          widget.onSignupSuccess?.call();
        } else if (state is SignupFailure) {
          // Registration failed
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
                      SizedBox(height: 40.h),

                      // Creative and fun title with emojis
                      Column(
                        children: [
                          Text(
                            ' Join the Fashion Revolution! ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Create Your Style Story',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 30.h),

                      // Profile image upload with avatar background
                      GestureDetector(
                        onTap: () {
                          // Handle image upload
                          print('Upload image tapped');
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: 102.r,
                              height: 102.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 2.w,
                                ),
                                image: DecorationImage(
                                  image: AssetImage('assets/images/avat3.png'),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.2),
                                    spreadRadius: 3,
                                    blurRadius: 15,
                                    offset: Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            // Camera icon overlay
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 30.r,
                                height: 30.r,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.w,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16.r,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30.h),

                      // Name field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name',
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
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 16.h,
                                ),
                                hintText: 'Enter your full name',
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

                      SizedBox(height: 10.h),

                      // Email or Username field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email or Username',
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
                                hintText: 'Enter email or username',
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

                      SizedBox(height: 10.h),

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
                                hintText: 'Create a strong password',
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

                      SizedBox(height: 20.h),

                      // Register button - bigger text
                      Container(
                        width: double.infinity,
                        height: 56.h,
                        child: BlocBuilder<SignupBloc, SignupState>(
                          builder: (context, state) {
                            bool isLoading = state is SignupLoading;
                            return ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      _handleRegister(context);
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
                                      'Register',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            22.sp, // Made bigger as requested
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 40.h),

                      // Sign in text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16.sp,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Handle sign in navigation
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
                                      builder: (context) => RovioLoginScreen(),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'Sign in',
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
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
