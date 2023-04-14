import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final Function() onTap;
  final String errMsg;
  final String title;
  final TextStyle? messageTextStyle;
  final ErrorButtonStyle? errorButtonStyle;
  final double? spaceBetween;
  final TextStyle? buttonTextStyle;

  const CustomErrorWidget(
      {Key? key,
      required this.onTap,
      required this.title,
      required this.errMsg,
      required this.messageTextStyle,
      required this.errorButtonStyle,
      required this.buttonTextStyle,
      required this.spaceBetween})
      : super(key: key);

  /// Custom Error Widget to show the error message if there is something wrong with location when qiblah compass in used
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.20,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            /// to show the error message here
            Center(
              child: Text(
                errMsg,
                textAlign: TextAlign.center,
                style: messageTextStyle ?? const TextStyle(color: Colors.red),
              ),
            ),
            SizedBox(
              height: spaceBetween ?? 10,
            ),

            /// error button with onTap callBack to retry
            Center(
              child: SizedBox(
                width: errorButtonStyle?.buttonWidth,
                height: errorButtonStyle?.buttonHeight,
                child: MaterialButton(
                  color: errorButtonStyle?.buttonColor ?? Colors.grey.shade300,
                  textColor: errorButtonStyle?.textColor ?? Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: errorButtonStyle?.borderRadius ??
                          BorderRadius.circular(5)),
                  onPressed: onTap,
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        style: buttonTextStyle,
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// for the decoration of button in error widget
class ErrorButtonStyle {
  BorderRadius? borderRadius;
  Color? buttonColor;
  Color? textColor;
  double? buttonHeight;
  double? buttonWidth;

  ErrorButtonStyle(
      {this.borderRadius,
      this.textColor,
      this.buttonColor,
      this.buttonHeight,
      this.buttonWidth});
}

/// for customizing error messages
class PermissionMessage {
  String? denied;
  String? permanentlyDenied;

  PermissionMessage({this.denied, this.permanentlyDenied});
}

///Model to Custom the error button text
class ButtonText {
  final String? onPermissionDenied;
  final String? onPermissionPermanentlyDenied;
  final String? onLocationDisabled;
  final TextStyle? textStyle;

  ButtonText(
      {this.onLocationDisabled,
      this.onPermissionDenied,
      this.textStyle,
      this.onPermissionPermanentlyDenied});
}

/// for customizing error widget
class ErrorDecoration {
  ErrorButtonStyle? buttonStyle;
  PermissionMessage? permissionMessage;
  double? spaceBetween;
  TextStyle? messageTextStyle;
  ButtonText? buttonText;

  ErrorDecoration(
      {this.buttonStyle,
      this.permissionMessage,
      this.spaceBetween,
      this.buttonText,
      this.messageTextStyle});
}
