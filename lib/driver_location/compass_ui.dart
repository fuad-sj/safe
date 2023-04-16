import 'dart:io';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'error_widget.dart';
import 'smooth_compass.dart';
import 'error_widget.dart';

double preValue = 0;
double turns = 0;

///custom callback for building widget
typedef WidgetBuilder = Widget Function(BuildContext context,
    AsyncSnapshot<CompassModel>? compassData, Widget compassAsset);

class SmoothCompass extends StatefulWidget {
  final WidgetBuilder? compassBuilder;
  final Widget? compassAsset;
  final Widget? loadingAnimation;
  final int? rotationSpeed;
  final double? height;
  final double? width;
  final bool? isDriverLocCompass;
  final ErrorDecoration? errorDecoration;

   SmoothCompass(
      {Key? key,
      this.compassBuilder,
      this.compassAsset,
      this.rotationSpeed = 400,
      this.height = 200,
      this.width = 200,
      this.isDriverLocCompass = true,
      this.loadingAnimation,
      this.errorDecoration})
      : super(key: key);

  @override
  State<SmoothCompass> createState() => _SmoothCompassState();
}

class _SmoothCompassState extends State<SmoothCompass> {
  var location = Location();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// check if the compass support available
    return FutureBuilder(
        future: Compass().isCompassAvailable(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return widget.loadingAnimation != null
                ? widget.loadingAnimation!
                : const Center(
                    child: CircularProgressIndicator(),
                  );
          }
          if (!snapshot.data!) {
            return const Center(
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                        "Compass support for this device is not available")));
          }

          /// start compass stream
          return widget.isDriverLocCompass!
              ? FutureBuilder<bool>(
                  future: location.serviceEnabled(),
                  builder: (context, AsyncSnapshot<bool> serviceSnapshot) {
                    if (serviceSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return widget.loadingAnimation ??
                          const Center(
                            child: CircularProgressIndicator(),
                          );
                    } else if (serviceSnapshot.data == false) {
                      return CustomErrorWidget(
                        title: widget.errorDecoration?.buttonText
                                ?.onLocationDisabled ??
                            "Enable Location",
                        buttonTextStyle:
                            widget.errorDecoration?.buttonText?.textStyle,
                        onTap: () async {
                          await location.requestService();
                          setState(() {});
                        },
                        errMsg: 'Location service is disabled',

                        /// check if custom error message style is provided else default will be used
                        messageTextStyle:
                            widget.errorDecoration?.messageTextStyle,

                        /// check if custom error buttonStyle is provided else default will be used
                        errorButtonStyle: widget.errorDecoration?.buttonStyle,

                        /// check if  spaceBetween is provided else default will be used
                        spaceBetween: widget.errorDecoration?.spaceBetween,
                      );
                    }

                    /// to Check Location permission if denied
                    return FutureBuilder<PermissionStatus>(
                        future: location.hasPermission(),
                        builder: (context,
                            AsyncSnapshot<PermissionStatus>
                                permissionSnapshot) {
                          if (permissionSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return widget.loadingAnimation ??
                                const Center(
                                  child: CircularProgressIndicator(),
                                );
                          } else if ((permissionSnapshot.data!) ==
                              PermissionStatus.denied) {
                            return CustomErrorWidget(
                              errMsg: widget.errorDecoration?.permissionMessage
                                      ?.denied ??
                                  "Please allow location permissions to get the qiblah direction for current location",
                              title: widget.errorDecoration?.buttonText
                                      ?.onPermissionDenied ??
                                  "Allow Permissions",
                              buttonTextStyle:
                                  widget.errorDecoration?.buttonText?.textStyle,
                              onTap: () async {
                                var status = await location.requestPermission();

                                if (status == PermissionStatus.granted ||
                                    status == PermissionStatus.grantedLimited) {
                                  setState(() {});
                                }
                              },

                              /// check if custom error message style is provided else default will be used
                              messageTextStyle:
                                  widget.errorDecoration?.messageTextStyle,

                              /// check if custom error buttonStyle is provided else default will be used
                              errorButtonStyle:
                                  widget.errorDecoration?.buttonStyle,

                              /// check if  spaceBetween is provided else default will be used
                              spaceBetween:
                                  widget.errorDecoration?.spaceBetween,
                            );
                          } else if ((permissionSnapshot.data ??
                                  PermissionStatus.deniedForever) ==
                              PermissionStatus.deniedForever) {
                            return Platform.isAndroid
                                ? CustomErrorWidget(
                                    onTap: () async {
                                      await location.requestPermission();
                                    },
                                    title: widget.errorDecoration?.buttonText
                                            ?.onPermissionPermanentlyDenied ??
                                        "Open Settings",
                                    buttonTextStyle: widget
                                        .errorDecoration?.buttonText?.textStyle,

                                    /// to show the error message
                                    errMsg: widget
                                            .errorDecoration
                                            ?.permissionMessage
                                            ?.permanentlyDenied ??
                                        "Location is permanently denied",

                                    /// check if custom error message style is provided else default will be used
                                    messageTextStyle: widget
                                        .errorDecoration?.messageTextStyle,

                                    /// check if custom error buttonStyle is provided else default will be used
                                    errorButtonStyle:
                                        widget.errorDecoration?.buttonStyle,

                                    /// check if  spaceBetween is provided else default will be used
                                    spaceBetween:
                                        widget.errorDecoration?.spaceBetween,
                                  )
                                : const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Center(
                                      child: Text(
                                          "please allow location permission from settings and privacy"),
                                    ),
                                  );
                          }
                          return FutureBuilder<LocationData?>(
                              future: location.getLocation(),
                              builder: (context,
                                  AsyncSnapshot<LocationData?>
                                      positionSnapshot) {
                                if (positionSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return widget.loadingAnimation ??
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                } else {
                                  /// if the all the permissions are granted and the location service of the device is enabled
                                  /// then compass will be displayed navigating to qiblah
                                  return StreamBuilder<CompassModel>(
                                    stream: Compass().compassUpdates(
                                        interval: const Duration(
                                          milliseconds: 200,
                                        ),
                                        azimuthFix: 0.0,
                                        currentLoc: MyLoc(
                                            latitude: positionSnapshot
                                                    .data?.latitude ??
                                                0,
                                            longitude: positionSnapshot
                                                    .data?.longitude ??
                                                0)),
                                    builder: (context,
                                        AsyncSnapshot<CompassModel> snapshot) {
                                      if (widget.compassAsset == null) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return widget.loadingAnimation ??
                                              const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                        }
                                        if (snapshot.hasError) {
                                          return Text(
                                              snapshot.error.toString());
                                        }
                                        return widget.compassBuilder == null
                                            ? _defaultWidget(snapshot, context)
                                            : widget.compassBuilder!(
                                                context,
                                                snapshot,
                                                _defaultWidget(
                                                    snapshot, context));
                                      } else {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return widget.loadingAnimation ??
                                              const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                        }
                                        if (snapshot.hasError) {
                                          return Text(
                                              snapshot.error.toString());
                                        }
                                        return widget.compassBuilder == null
                                            ? AnimatedRotation(
                                                turns:
                                                    snapshot.data!.turns * -1,
                                                duration: Duration(
                                                    milliseconds:
                                                        widget.rotationSpeed!),
                                                child: widget.compassAsset!,
                                              )
                                            : widget.compassBuilder!(
                                                context,
                                                snapshot,
                                                AnimatedRotation(
                                                  turns:
                                                      snapshot.data!.turns * -1,
                                                  duration: Duration(
                                                      milliseconds: widget
                                                          .rotationSpeed!),
                                                  child: widget.compassAsset!,
                                                ),
                                              );
                                      }
                                    },
                                  );
                                }
                              });
                        });
                  })

              /// if isQiblahCompass is not true, the simple compass will be displayed
              : StreamBuilder<CompassModel>(
                  stream: Compass().compassUpdates(
                      interval: const Duration(
                        milliseconds: 200,
                      ),
                      azimuthFix: 0.0,
                      currentLoc: MyLoc(latitude: 0, longitude: 0)),
                  builder: (context, AsyncSnapshot<CompassModel> snapshot) {
                    if (widget.compassAsset == null) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return widget.loadingAnimation ??
                            const Center(
                              child: CircularProgressIndicator(),
                            );
                      }
                      if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }
                      return widget.compassBuilder == null
                          ? _defaultWidget(snapshot, context)
                          : widget.compassBuilder!(context, snapshot,
                              _defaultWidget(snapshot, context));
                    } else {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return widget.loadingAnimation ??
                            const Center(
                              child: CircularProgressIndicator(),
                            );
                      }
                      if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }
                      return widget.compassBuilder == null
                          ? AnimatedRotation(
                              turns: snapshot.data!.turns * -1,
                              duration:
                                  Duration(milliseconds: widget.rotationSpeed!),
                              child: widget.compassAsset!,
                            )
                          : widget.compassBuilder!(
                              context,
                              snapshot,
                              AnimatedRotation(
                                turns: snapshot.data!.turns * -1,
                                duration: Duration(
                                    milliseconds: widget.rotationSpeed!),
                                child: widget.compassAsset!,
                              ),
                            );
                    }
                  },
                );
        });
  }

  ///default widget if custom widget isn't provided
  Widget _defaultWidget(
      AsyncSnapshot<CompassModel> snapshot, BuildContext context) {
    return AnimatedRotation(
      turns: snapshot.data!.turns,
      duration: Duration(milliseconds: widget.rotationSpeed!),
      child: Container(
        height: widget.height ?? MediaQuery.of(context).size.shortestSide * 0.8,
        width: widget.width ?? MediaQuery.of(context).size.shortestSide * 0.8,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/compass.png',
                    package: 'smooth_compass'),
                fit: BoxFit.cover)),
      ),
    );
  }
}

///calculating compass Model
getCompassValues(double heading, double latitude, double longitude) {
  double direction = heading;
  direction = direction < 0 ? (360 + direction) : direction;

  double diff = direction - preValue;
  if (diff.abs() > 180) {
    if (preValue > direction) {
      diff = 360 - (direction - preValue).abs();
    } else {
      diff = (360 - (preValue - direction).abs()).toDouble();
      diff = diff * -1;
    }
  }

  turns += (diff / 360);
  preValue = direction;

  return CompassModel(
      turns: -1 * turns,
      angle: heading,
      driverLocOffset: getDriverDirection(latitude, longitude, heading));
}

/// model to store the sensor value
class CompassModel {
  double turns;
  double angle;
  double driverLocOffset;

  CompassModel(
      {required this.turns, required this.angle, required this.driverLocOffset});
}
