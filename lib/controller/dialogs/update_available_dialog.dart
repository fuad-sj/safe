import 'package:flutter/material.dart';

typedef DismissCallback = Future<bool> Function();

class UpdateAvailableDialog extends StatefulWidget {
  static final String DIALOG_RESULT_OKAY_PRESSED = "dialog_result_okay_pressed";
  static final String DIALOG_RESULT_CANCEL_PRESSED =
      "dialog_result_cancel_pressed";

  bool isUpdateForceful;

  DismissCallback updateBtnClicked;
  DismissCallback cancelBtnClicked;

  UpdateAvailableDialog({
    Key? key,
    required this.isUpdateForceful,
    required this.updateBtnClicked,
    required this.cancelBtnClicked,
  }) : super(key: key);

  @override
  State<UpdateAvailableDialog> createState() => _UpdateAvailableDialogState();
}

class _UpdateAvailableDialogState extends State<UpdateAvailableDialog> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double edgePadding = screenWidth * 0.10 / 2.0; // 10% of screen width

    double HORIZONTAL_PADDING = 15.0;
    return Dialog(
      elevation: 2.0,
      insetPadding: EdgeInsets.symmetric(horizontal: edgePadding),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Dialog Header
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xffDE0000),
                    Color(0xff990000),
                  ],
                ),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0))),
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'Update Available',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    fontFamily: 'Lato'),
              ),
            ),
          ),
          SizedBox(height: 15.0),
          Center(
            child: Icon(Icons.security_update_rounded,
                size: 50.0, color: Colors.teal.shade400),
          ),
          SizedBox(height: 10.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              widget.isUpdateForceful
                  ? "Update your app to continue using our service"
                  : 'A new update is available, update your app',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 15.0,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1),
            ),
          ),
          SizedBox(height: 20.0),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              children: [
                if (!widget.isUpdateForceful) ...[
                  Expanded(child: Container()),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(primary: Colors.grey.shade500),
                    onPressed: () async {
                      if (await widget.cancelBtnClicked()) {
                        Navigator.pop(context,
                            UpdateAvailableDialog.DIALOG_RESULT_CANCEL_PRESSED);
                      }
                    },
                    child: Container(
                      width: screenWidth * 0.20,
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      child: Center(child: Text("Cancel")),
                    ),
                  ),
                ],
                Expanded(child: Container()),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Color(0xffDE0000)),
                  onPressed: () async {
                    if (await widget.updateBtnClicked()) {
                      Navigator.pop(context,
                          UpdateAvailableDialog.DIALOG_RESULT_OKAY_PRESSED);
                    }
                  },
                  child: Container(
                    width: screenWidth * 0.20,
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    child: Center(child: Text("Update App")),
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
