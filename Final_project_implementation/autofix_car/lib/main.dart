// main.dart
import 'package:flutter/material.dart';
import 'package:autofix_car/constants/app_colors.dart';
import 'package:autofix_car/constants/app_styles.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:autofix_car/pages/landing_page.dart';
import 'package:autofix_car/pages/main_navigation.dart';
import 'package:autofix_car/services/token_manager.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize Firebase Core
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr')],
      path: 'l10n',
      fallbackLocale: const Locale('en'),
      child: const AutoFixApp(),
    ),
  );
}

class AutoFixApp extends StatelessWidget {
  const AutoFixApp({super.key});

  Future<bool> _checkLoginStatus() async {
    return await TokenManager.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoFix',
      theme: ThemeData(
        primarySwatch: AppColors.primaryMaterialColor,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: AppStyles.headline1,
          displayMedium: AppStyles.headline2,
          displaySmall: AppStyles.headline3,
          bodyLarge: AppStyles.bodyText1,
          bodyMedium: AppStyles.bodyText2,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            if (snapshot.hasData && snapshot.data == true) {
              return const MainNavigation();
            } else {
              return const LandingPage();
            }
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}