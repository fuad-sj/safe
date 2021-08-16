import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          backgroundColor: Color(0xfe7a110a),
          elevation: 0.0,
          leading: new BackButton(color: Colors.black),
          title: Text(SafeLocalizations.of(context)!.nav_header_profile),
          actions: <Widget>[]),
      body: Container(),
    );
  }
}
