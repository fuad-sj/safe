import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          backgroundColor: Color(0xfe7a110a),
          elevation: 0.0,
          leading: new BackButton(color: Colors.black),
          title: Text(SafeLocalizations.of(context)!.nav_option_settings),
          actions: <Widget>[]),
      body: Container(),
    );
  }
}
