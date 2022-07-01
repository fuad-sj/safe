import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/controller/login_page.dart';
import 'package:safe/controller/main_screen_customer.dart';
import 'package:safe/controller/registration_screen.dart';
import 'package:safe/controller/customer_profile_screen.dart';
import 'package:safe/current_locale.dart';
import 'package:safe/pickup_and_dropoff_locations.dart';
import 'package:safe/utils/pref_util.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PrefUtil.getInstance(); // load SharedPreferences

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
          title: 'Safe Rider',
          locale: Provider.of<CurrentLocale>(context).getLocale,
          localizationsDelegates: SafeLocalizations.localizationsDelegates,
          supportedLocales: SafeLocalizations.supportedLocales,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: FirebaseAuth.instance.currentUser == null
              ? LoginPage.idScreen
              : MainScreenCustomer.idScreen,
          routes: {
            RegistrationScreen.idScreen: (_) => RegistrationScreen(),
            LoginPage.idScreen: (_) => LoginPage(),
            MainScreenCustomer.idScreen: (_) => MainScreenCustomer(),
            CustomerProfileScreen.idScreen: (_) => CustomerProfileScreen(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
