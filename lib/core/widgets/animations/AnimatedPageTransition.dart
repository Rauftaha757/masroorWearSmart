import 'package:flutter/material.dart';

class AnimatedPageTransition extends StatefulWidget {
  final Widget child;
  final AnimationController controller;
  final bool isLogin;

  const AnimatedPageTransition({
    Key? key,
    required this.child,
    required this.controller,
    required this.isLogin,
  }) : super(key: key);

  @override
  State<AnimatedPageTransition> createState() => _AnimatedPageTransitionState();
}

class _AnimatedPageTransitionState extends State<AnimatedPageTransition>
    with TickerProviderStateMixin {
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Slide animation - slides from right to left for signup, left to right for login
    _slideAnimation =
        Tween<double>(begin: widget.isLogin ? -1.0 : 1.0, end: 0.0).animate(
          CurvedAnimation(parent: widget.controller, curve: Curves.easeInOut),
        );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.easeInOut),
    );

    // Scale animation for a subtle zoom effect
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.easeOutBack),
    );

    // Start the animation
    widget.controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _slideAnimation.value * MediaQuery.of(context).size.width,
            0,
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(opacity: _fadeAnimation.value, child: widget.child),
          ),
        );
      },
    );
  }
}

class PageTransitionRoute extends PageRouteBuilder {
  final Widget child;
  final bool isLogin;

  PageTransitionRoute({required this.child, required this.isLogin})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionDuration: Duration(milliseconds: 400),
        reverseTransitionDuration: Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide transition
          final slideAnimation =
              Tween<Offset>(
                begin: isLogin ? Offset(-1.0, 0.0) : Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              );

          // Fade transition
          final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );

          // Scale transition
          final scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          );

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(scale: scaleAnimation, child: child),
            ),
          );
        },
      );
}
