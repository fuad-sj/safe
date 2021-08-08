import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/controller/login_page.dart';
import 'package:safe/controller/main_screen_customer.dart';
import 'package:safe/controller/registration_screen.dart';
import 'package:safe/pickup_and_dropoff_locations.dart';
import 'package:safe/utils/pref_util.dart';
import 'package:safe/constants.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PrefUtil.getInstance(); // load SharedPreferences

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PickUpAndDropOffLocations(),
      child: MaterialApp(
        title: 'Safe Rider',
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
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
