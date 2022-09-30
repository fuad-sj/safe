import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:safe/controller/bottom_sheets/base_bottom_sheet.dart';
import 'package:safe/controller/otp_text_field/otp_field.dart';
import 'package:safe/controller/otp_text_field/style.dart';
import 'package:safe/models/color_constants.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/pickup_and_dropoff_locations.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

class ActivateReferralCodeBottomSheet extends BaseBottomSheet {
  static const String KEY = 'WhereToBottomSheet';

  static const double HEIGHT_WHERE_TO_RECOMMENDED_HEIGHT = 180;
  static const double HEIGHT_WHERE_TO_PERCENT = 0.28;
  static const double TOP_CORNER_BORDER_RADIUS = 8.0;

  ActivateReferralCodeBottomSheet({
    required TickerProvider tickerProvider,
    required bool showBottomSheet,
    required VoidCallback actionCallback,
  }) : super(
          tickerProvider: tickerProvider,
          showBottomSheet: showBottomSheet,
          onActionCallback: actionCallback,
        );

  @override
  double bottomSheetHeight(BuildContext context) {
    double sheetHeight =
        MediaQuery.of(context).size.height * HEIGHT_WHERE_TO_PERCENT;

    return sheetHeight;
  }

  @override
  double topCornerRadius(BuildContext context) {
    return TOP_CORNER_BORDER_RADIUS;
  }

  @override
  double bottomOffset(BuildContext context) {
    return 0.45;
  }

  @override
  bool showBoxShadow(BuildContext context) {
    return false;
  }

  @override
  State<StatefulWidget> buildState() {
    return new _ActivateReferralCodeBottomSheetState();
  }
}

class _ActivateReferralCodeBottomSheetState
    extends State<ActivateReferralCodeBottomSheet>
    implements BottomSheetWidgetBuilder {
  String _referralCode = "";

  @override
  Widget buildContent(BuildContext context) {
    double HSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.width;
    }

    double VSpace(double ratio) {
      return ratio * MediaQuery.of(context).size.height;
    }

    int _refState = -1;

    if (_referralCode.length < 10) {
      _refState = 0;
    } else if (Customer.isReferralCodeValid(_referralCode)) {
      _refState = 1;
    } else {
      _refState = 2;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: HSpace(0.04)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
              child: Container(
                  margin: EdgeInsets.only(top: VSpace(0.005)),
                  width: 30.0,
                  height: 2.0,
                  color: Colors.grey.shade700)),

          SizedBox(height: VSpace(0.024)),

          //
          OTPTextField(
            length: 10,
            width: MediaQuery.of(context).size.width,
            textFieldAlignment: MainAxisAlignment.spaceAround,
            fieldWidth: 25,
            fieldStyle: FieldStyle.underline,
            outlineBorderRadius: 8,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            keyboardType: TextInputType.text,
            onChanged: (val) {
              setState(() {
                _referralCode = val;
              });
            },
            onCompleted: (val) {
              setState(() {
                _referralCode = val;
              });
            },
          ),

          SizedBox(height: VSpace(0.015)),
          RoundedLoadingButton(
            controller: RoundedLoadingButtonController(),
            onPressed: () async {},
            child: Text(
              'VERIFY',
              style: TextStyle(color: Colors.white),
            ),
            color: _refState == 0
                ? Colors.blue.shade800
                : (_refState == 1
                    ? Colors.green.shade800
                    : Colors.red.shade800),
          ),

          SizedBox(height: VSpace(0.02)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.wrapContent(context, buildContent);
  }
}
