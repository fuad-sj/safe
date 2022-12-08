import 'package:flutter/material.dart';

abstract class BottomSheetWidgetBuilder {
  Widget buildContent(BuildContext context);
}

abstract class BaseBottomSheet extends StatefulWidget {
  static const int ANIMATION_DURATION = 220;

  final TickerProvider tickerProvider;
  final bool showBottomSheet;
  final VoidCallback onActionCallback;
  final bool fixedToBottom;

  BaseBottomSheet({
    Key? key,
    required this.tickerProvider,
    required this.showBottomSheet,
    required this.onActionCallback,
    this.fixedToBottom = false,
  }) : super(key: key);

  double bottomSheetHeight(BuildContext context);

  double topCornerRadius(BuildContext context);

  /// Subclasses should override this if they want to have height set by {@code bottomSheetHeight}
  bool haveWrappedHeight(BuildContext context) {
    return true;
  }

  double bottomOffsetPercentHeight(BuildContext context) {
    return 0;
  }

  bool showBoxShadow(BuildContext context) {
    return true;
  }

  State<StatefulWidget> buildState();

  @override
  State<StatefulWidget> createState() {
    return buildState();
  }

  int animationDuration() {
    return ANIMATION_DURATION;
  }

  Widget wrapContent(BuildContext context, WidgetBuilder builder) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double padding = screenWidth * 0.02; // 2% of screen width
    double offset = fixedToBottom || (showBottomSheet == false) ? 0 : padding;

    BorderRadius radius;

    if (fixedToBottom) {
      radius = BorderRadius.only(
          topLeft: Radius.circular(topCornerRadius(context)),
          topRight: Radius.circular(topCornerRadius(context)));
    } else {
      radius = BorderRadius.all(Radius.circular(topCornerRadius(context)));
    }

    Decoration? decoration = (showBottomSheet == false)
        ? null
        : BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            boxShadow: !showBoxShadow(context)
                ? []
                : [
                    BoxShadow(
                      color: Colors.grey.shade500,
                      blurRadius: 16.0,
                      //blurRadius: 8.0,
                      spreadRadius: 0.5,
                      //offset: Offset(0.7, 0.7),
                    ),
                    BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8.0,
                        offset: Offset(-1, 10)),
                    BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8.0,
                        offset: Offset(1, 10)),
                    BoxShadow(
                        color: Colors.white,
                        blurRadius: 24.0,
                        offset: Offset(0, 10)),
                  ],
          );

    Widget child = showBottomSheet ? builder(context) : Container();

    return Positioned(
      bottom: offset * 0.2 + bottomOffsetPercentHeight(context) * screenHeight,
      left: offset,
      right: offset,
      child: AnimatedSize(
        vsync: tickerProvider,
        curve: Curves.bounceIn,
        duration: Duration(milliseconds: animationDuration()),
        child: haveWrappedHeight(context)
            ? Container(
                decoration: decoration,
                child: child,
              )
            : Container(
                height: showBottomSheet ? bottomSheetHeight(context) : 0,
                decoration: decoration,
                child: child,
              ),
      ),
    );
  }
}
