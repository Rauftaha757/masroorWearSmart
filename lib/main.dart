import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'features/auth/auth_wrapper.dart';
import 'core/services/storage_service.dart';
import 'core/services/connectivity_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Flutter Secure Storage
  try {
    await StorageService.initialize();
    print('Storage service initialized successfully');
  } catch (e) {
    print('Failed to initialize storage service: $e');
  }

  // Test backend connectivity
  await ConnectivityTest.testBackendConnection();
  await ConnectivityTest.testAuthEndpoint();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ResponsiveWrapper(),
    );
  }
}

class ResponsiveWrapper extends StatelessWidget {
  const ResponsiveWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen dimensions
        final screenWidth = constraints.maxWidth;

        Size designSize;

        if (screenWidth <= 480) {
          designSize = const Size(375, 812);
        } else if (screenWidth <= 768) {
          designSize = const Size(414, 896);
        } else if (screenWidth <= 1024) {
          designSize = const Size(768, 1024);
        } else {
          designSize = const Size(1024, 768);
        }

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                fontFamily: 'PublicSans',
                textTheme: const TextTheme(
                  displayLarge: TextStyle(fontFamily: 'PublicSans'),
                  displayMedium: TextStyle(fontFamily: 'PublicSans'),
                  displaySmall: TextStyle(fontFamily: 'PublicSans'),
                  headlineLarge: TextStyle(fontFamily: 'PublicSans'),
                  headlineMedium: TextStyle(fontFamily: 'PublicSans'),
                  headlineSmall: TextStyle(fontFamily: 'PublicSans'),
                  titleLarge: TextStyle(fontFamily: 'PublicSans'),
                  titleMedium: TextStyle(fontFamily: 'PublicSans'),
                  titleSmall: TextStyle(fontFamily: 'PublicSans'),
                  bodyLarge: TextStyle(fontFamily: 'PublicSans'),
                  bodyMedium: TextStyle(fontFamily: 'PublicSans'),
                  bodySmall: TextStyle(fontFamily: 'PublicSans'),
                  labelLarge: TextStyle(fontFamily: 'PublicSans'),
                  labelMedium: TextStyle(fontFamily: 'PublicSans'),
                  labelSmall: TextStyle(fontFamily: 'PublicSans'),
                ),
              ),
              home: AuthWrapper(),
            );
          },
        );
      },
    );
  }
}
