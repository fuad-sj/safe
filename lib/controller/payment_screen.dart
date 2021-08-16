import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          backgroundColor: Color(0xfe7a110a),
          elevation: 0.0,
          leading: new BackButton(color: Colors.black),
          title: Text(SafeLocalizations.of(context)!.nav_option_payment),
          actions: <Widget>[]),
      body: Container(),
    );
  }
}
