import 'package:flutter/material.dart';

class SliderButton extends StatefulWidget {
  final String sliderKey;

  ///Sets the radius of corners of a button.
  final double? radius;

  ///Use it to define a height and width of widget.
  final double height;
  final double? width;
  final double? buttonSize;

  ///Use it to define a color of widget.
  final Color? backgroundColor;
  final Color buttonColor;

  ///Change it to gave a label on a widget of your choice.
  final Text label;

  ///Gives a alignment to a slider icon.
  final Alignment alignLabel;
  final BoxShadow boxShadow;
  final Widget icon;
  final Function action;

  ///The offset threshold the item has to be dragged in order to be considered
  ///dismissed e.g. if it is 0.4, then the item has to be dragged
  /// at least 40% towards one direction to be considered dismissed
  final double dismissThresholds;

  final bool resetSlider;

  final ConfirmDismissCallback? shouldDismissCallback;

  SliderButton({
    required this.sliderKey,
    required this.action,
    this.radius = 35,
    required this.boxShadow,
    this.height = 70,
    this.buttonSize,
    this.width,
    this.alignLabel = const Alignment(0, 0),
    this.backgroundColor,
    this.buttonColor = Colors.white,
    required this.label,
    required this.icon,
    this.dismissThresholds = 0.7,
    this.resetSlider = false,
    this.shouldDismissCallback,
  }) : assert((buttonSize ?? 60) <= height);

  @override
  _SliderButtonState createState() => _SliderButtonState();
}

class _SliderButtonState extends State<SliderButton> {
  bool _showSlider = true;

  /**
   * When a new slider is instantiated, reset the [_showSlider] state
   */
  @override
  void didUpdateWidget(SliderButton old) {
    super.didUpdateWidget(old);
    if (old.sliderKey != widget.sliderKey) {
      _showSlider = true;
      setState(() {});
    }
  }

  Widget _slider() {
    if (widget.shouldDismissCallback != null) {
      return Dismissible(
        //key: Key(widget.sliderKey),
        key: UniqueKey(),
        direction: DismissDirection.startToEnd,
        dismissThresholds: {
          DismissDirection.startToEnd: widget.dismissThresholds
        },
        onDismissed: (dir) async {
          setState(() {
            _showSlider = false;
          });

          widget.action();
        },
        confirmDismiss: widget.shouldDismissCallback,
        child: Container(
          width: (widget.width ?? 250) - widget.height,
          //height: widget.height,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(
            left:
                (widget.height - (widget.buttonSize ?? widget.height * 0.90)) /
                    2,
          ),
          child: widget.icon,
        ),
      );
    } else {
      return Dismissible(
        key: Key(widget.sliderKey),
        //key: UniqueKey(),
        direction: DismissDirection.startToEnd,
        dismissThresholds: {
          DismissDirection.startToEnd: widget.dismissThresholds
        },
        onDismissed: (dir) async {
          setState(() {
            _showSlider = false;
          });

          widget.action();
        },
        child: Container(
          width: (widget.width ?? 250) - widget.height,
          //height: widget.height,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(
            left:
                (widget.height - (widget.buttonSize ?? widget.height * 0.90)) /
                    2,
          ),
          child: widget.icon,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration;

    if (widget.backgroundColor != null) {
      decoration = BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.radius ?? 100));
    } else {
      decoration = BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius ?? 100));
    }

    return Container(
      height: widget.height,
      width: widget.width ?? 250,
      decoration: decoration,
      alignment: Alignment.centerLeft,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            alignment: widget.alignLabel,
            child: widget.label,
          ),
          if (_showSlider) ...[
            _slider(),
          ],
          Container(
            child: SizedBox.expand(),
          ),
        ],
      ),
    );
  }
}
