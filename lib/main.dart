import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/controller/login_page.dart';
import 'package:safe/controller/main_screen_customer.dart';
import 'package:safe/controller/registration_screen.dart';
import 'package:safe/controller/customer_profile_screen.dart';
import 'package:safe/controller/welcome_screen.dart';
import 'package:safe/current_locale.dart';
import 'package:safe/notification_service.dart';
import 'package:safe/pickup_and_dropoff_locations.dart';
import 'package:safe/utils/pref_util.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

import 'controller/verify_otp_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PrefUtil.getInstance(); // load SharedPreferences

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await NotificationService.init();

  if (Platform.isAndroid) {
    FirebaseMessaging.onBackgroundMessage(firebaseFCMBackgroundHandler);
  }

  String previousLocale = PrefUtil.getUserLanguageLocale();

  runApp(MainApp(defaultLocale: previousLocale));
}

class MainApp extends StatelessWidget {
  String defaultLocale;

  @override
  MainApp({Key? key, required this.defaultLocale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PickUpAndDropOffLocations()),
        ChangeNotifierProvider(create: (_) => CurrentLocale(defaultLocale)),
      ],
      builder: (context, child) {
        return MaterialApp(
          title: 'Safe Passenger',
          locale: Provider.of<CurrentLocale>(context).getLocale,
          localizationsDelegates: SafeLocalizations.localizationsDelegates,
          supportedLocales: SafeLocalizations.supportedLocales,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: WelcomeScreen.idScreen,
          routes: {
            WelcomeScreen.idScreen: (_) => WelcomeScreen(),
            RegistrationScreen.idScreen: (_) => RegistrationScreen(),
            LoginPage.idScreen: (_) => LoginPage(),
            MainScreenCustomer.idScreen: (_) => MainScreenCustomer(),
            CustomerProfileScreenNew.idScreen: (_) =>
                CustomerProfileScreenNew(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
