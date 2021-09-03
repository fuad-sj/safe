import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

class DriverNotFoundDialog extends StatefulWidget {
  const DriverNotFoundDialog({Key? key}) : super(key: key);

  @override
  _DriverNotFoundDialogState createState() => _DriverNotFoundDialogState();
}

class _DriverNotFoundDialogState extends State<DriverNotFoundDialog> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double edgePadding = screenWidth * 0.10 / 2.0; // 10% of screen width

    double HORIZONTAL_PADDING = 15.0;

    return Dialog(
      elevation: 2.0,
      insetPadding: EdgeInsets.symmetric(horizontal: edgePadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dialog Header
          Container(
            color: Colors.redAccent,
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                SafeLocalizations.of(context)!.dialog_driver_not_found_title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
          SizedBox(height: 15.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
            width: (screenWidth - 2 * HORIZONTAL_PADDING),
            child: Center(
                child: Text(
                    SafeLocalizations.of(context)!.dialog_driver_not_found_body,
                    style: TextStyle(fontSize: 14.0))),
          ),
          SizedBox(height: 15.0),

          // Done Trip
          Container(
            padding: EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // pop off the dialog
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.deepOrangeAccent),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      width: double.infinity,
                      child: Center(
                        child: Text(
                            SafeLocalizations.of(context)!
                                .dialog_driver_not_found_dismiss,
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.0),
        ],
      ),
    );
  }
}
