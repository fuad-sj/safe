import 'package:flutter/material.dart';

class UpdateAvailableDialog extends StatefulWidget {
  static final String DIALOG_RESULT_OKAY_PRESSED = "dialog_result_okay_pressed";
  static final String DIALOG_RESULT_CANCEL_PRESSED =
      "dialog_result_cancel_pressed";

  bool isUpdateForceful;
  String updateVersionNumber;
  VoidCallback updateBtnClicked;

  UpdateAvailableDialog(
      {Key? key,
      required this.isUpdateForceful,
        required this.updateVersionNumber,
      required this.updateBtnClicked})
      : super(key: key);

  @override
  State<UpdateAvailableDialog> createState() => _UpdateAvailableDialogState();
}

class _UpdateAvailableDialogState extends State<UpdateAvailableDialog> {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Dialog Header
          Container(
            color: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                "Update Available",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Center(
            child: Icon(Icons.location_on_outlined,
                size: 50.0, color: Colors.blueAccent),
          ),
          SizedBox(height: 10.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
                "Please update as a new version ${widget.updateVersionNumber} is available"),
          ),
          SizedBox(height: 20.0),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              children: [
                if (!widget.isUpdateForceful) ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context,
                          UpdateAvailableDialog.DIALOG_RESULT_CANCEL_PRESSED);
                    },
                    child: Text("Cancel"),
                  ),
                ],
                Expanded(child: Container()),
                ElevatedButton(
                  onPressed: () {
                    widget.updateBtnClicked();
                    if (!widget.isUpdateForceful) {
                      Navigator.pop(context,
                          UpdateAvailableDialog.DIALOG_RESULT_OKAY_PRESSED);
                    }
                  },
                  child: Text("Update App"),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
          SizedBox(height: 5.0),
        ],
      ),
    );
  }
}
