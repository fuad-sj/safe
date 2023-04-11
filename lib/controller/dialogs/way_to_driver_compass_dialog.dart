import 'package:flutter/material.dart';
import 'package:smooth_compass/utils/src/compass_ui.dart';

class WayToDriverCompassDialog extends StatefulWidget {
  const WayToDriverCompassDialog({Key? key}) : super(key: key);

  @override
  State<WayToDriverCompassDialog> createState() =>
      _WayToDriverCompassDialogState();
}

class _WayToDriverCompassDialogState extends State<WayToDriverCompassDialog> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: SmoothCompass(
        compassBuilder: (context, snapshot, child) {
          return Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    backgroundColor: Colors.transparent,
                    child: const Icon(Icons.cancel_sharp, size: 60, color: Color(0xfff82323)),
                  ),
                ),
                SizedBox(height: 50),
                Center(
                  child: AnimatedRotation(
                    turns: snapshot?.data?.turns ?? 0,
                    duration: Duration(milliseconds: 400),
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("images/arrow.png"),
                            fit: BoxFit.fill),
                      ),
                    ),
                  ),
                ),
                SizedBox(height:50),
                Text(
                  "${snapshot?.data?.angle.toStringAsFixed(2)??0}",
                  style: TextStyle(
                    fontSize: 22.0,
                    fontFamily: 'Lato',
                    color: Color.fromRGBO(28, 20, 20, 1.0),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
