import 'package:flutter/material.dart';

class CustomProgressDialog extends StatelessWidget {
  final String message;

  CustomProgressDialog({required this.message});

  static void showProgressDialog({
    required BuildContext context,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (_) => CustomProgressDialog(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              SizedBox(width: 6.0),
              CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
              SizedBox(width: 26.0),
              Text(
                message,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
