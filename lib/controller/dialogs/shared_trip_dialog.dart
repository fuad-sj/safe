import 'package:flutter/material.dart';

class ShowSharedDialog extends StatefulWidget {
  const ShowSharedDialog({Key? key}) : super(key: key);

  @override
  State<ShowSharedDialog> createState() => _ShowSharedDialogState();
}

class _ShowSharedDialogState extends State<ShowSharedDialog> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.25,
            left: MediaQuery.of(context).size.width * 0.030,
            right: MediaQuery.of(context).size.width * 0.030),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                backgroundColor: Colors.transparent,
                child:
                    const Icon(Icons.cancel_sharp, size: 60, color: Color(
                        0xfff82323)),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25.0),
                    bottomRight: Radius.circular(25.0),
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                  image: DecorationImage(
                      image: AssetImage("images/shared.png"),
                      fit: BoxFit.cover),
                ),
                height: MediaQuery.of(context).size.height * 0.265,
              )
            ],
          ),
        ));
  }
}
