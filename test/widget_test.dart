// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// controller.graphview.tree, read text, and verify that the values of widget properties are correct.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

import 'package:safe/main.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';
import 'package:vector_math/vector_math.dart' show degrees, radians;

void main() {
  testWidgets('Averaging bearing angles', (WidgetTester tester) async {
    // Build our app and trigger a frame.

    const int LOCATIONS_SMOOTHING_WINDOW = 4;
    const SMOOTHING_FACTOR_ALPHA_CURRENT = 0.95;
    const SMOOTHING_FACTOR_CURRENT_POWER_MULTIPLIER = 1.1;

    const TURN_ANGLE_THRESHOLD_MIN = 15.0;
    const TURN_ANGLE_THRESHOLD_MAX = 60.0;

    const DELTA_ANGLE_COS_POW_FACTOR = 10.0;

    const int TURN_TYPE_NONE = -1;
    const int TURN_TYPE_RIGHT = 1;
    const int TURN_TYPE_LEFT = 2;

    List<double> arrSmoothedAngles = [];
    LatLng? smoothedCurrentLocation;
    LatLng? smoothedPreviousLocation;
    int arrAngleIndex = 0;

    String appendLocationToPolyline(String previousRoute, LatLng location) {
      List<List<num>> coords = [];
      if (previousRoute.isNotEmpty) {
        coords = decodePolyline(previousRoute);
      }
      coords.add([location.latitude, location.longitude]);
      return encodePolyline(coords);
    }

    LatLng endPointWithBearing(
        LatLng startPoint, double bearing, double distance) {
      var earthRadius = 6378137.0;

      bearing = radians(bearing);

      var angDist = distance / earthRadius;

      var lat1 = radians(startPoint.latitude);
      var lng1 = radians(startPoint.longitude);

      var lat2 = degrees(asin(
          sin(lat1) * cos(angDist) + cos(lat1) * sin(angDist) * cos(bearing)));
      var lng2 = degrees(lng1 +
          atan2(sin(bearing) * sin(angDist) * cos(lat1),
              cos(angDist) - sin(lat1) * sin(lat2)));

      return LatLng(lat2.toDouble(), lng2.toDouble());
    }

    void computeSmoothedLocation(LatLng newLoc) {
      if (smoothedCurrentLocation == null) {
        smoothedCurrentLocation = newLoc;
        return;
      }

      double bearing = (Geolocator.bearingBetween(
                  smoothedCurrentLocation!.latitude,
                  smoothedCurrentLocation!.longitude,
                  newLoc.latitude,
                  newLoc.longitude) +
              360) %
          360;

      if (LOCATIONS_SMOOTHING_WINDOW > arrSmoothedAngles.length) {
        arrSmoothedAngles.add(bearing);
      } else {
        arrSmoothedAngles[arrAngleIndex] = bearing;
      }

      int counter = 0;
      int i = arrAngleIndex;

      double smoothedBearing = 0.0;

      double totalWeight = 0.0;

      int turnType = TURN_TYPE_NONE;
      double correctTurnWeight = 0;
      double totalTurnWeight = 0;

      double prevAngle = -1.0;

      while (counter < arrSmoothedAngles.length) {
        double weight = pow(SMOOTHING_FACTOR_ALPHA_CURRENT,
                counter * SMOOTHING_FACTOR_CURRENT_POWER_MULTIPLIER)
            .toDouble();

        double relativeAngle = arrSmoothedAngles[i] -
            (smoothedBearing / (totalWeight == 0 ? 1 : totalWeight));
        double adjAngle = arrSmoothedAngles[i];

        if (relativeAngle < -180) {
          adjAngle += 360.0;
          relativeAngle += 360.0;
        } else if (relativeAngle > 180) {
          // if we're past the first iteration and relative angle is actually saying our delta from prev is > 180
          if (counter != 0) {
            adjAngle -= 360.0;
            relativeAngle -= 360.0;
          }
        }

        if (counter > 0) {
          double deltaPrevFromCurrent = prevAngle - arrSmoothedAngles[i];
          if (deltaPrevFromCurrent < -180.0) deltaPrevFromCurrent += 360.0;
          // the turn direction is defined by the first delta angle

          if (deltaPrevFromCurrent.abs() > TURN_ANGLE_THRESHOLD_MIN &&
              deltaPrevFromCurrent.abs() < TURN_ANGLE_THRESHOLD_MAX) {
            if (counter == 1) {
              turnType =
                  deltaPrevFromCurrent > 0 ? TURN_TYPE_RIGHT : TURN_TYPE_LEFT;
              correctTurnWeight = weight;
            } else {
              if (deltaPrevFromCurrent > 0 && turnType == TURN_TYPE_RIGHT) {
                correctTurnWeight += weight;
              } else if (deltaPrevFromCurrent < 0 &&
                  turnType == TURN_TYPE_LEFT) {
                correctTurnWeight += weight;
              }
            }
          }
          totalTurnWeight += weight;
        }
        prevAngle = arrSmoothedAngles[i];

        totalWeight += weight;
        smoothedBearing += adjAngle * weight;

        // if you hit left most part, cycle back to far right
        if (--i < 0) {
          i = arrSmoothedAngles.length - 1;
        }
        counter++;
      }

      if (totalWeight > 0) {
        smoothedBearing = (smoothedBearing / totalWeight) % 360.0;
        double actualBearing = arrSmoothedAngles[arrAngleIndex];

        double deltaBearing = (actualBearing - smoothedBearing);
        if (deltaBearing < -180.0) {
          deltaBearing += 360.0;
        }

        // turn is considered monotonic is most(i.e: 50%+) of its movements are in the correct direction
        bool isMonotonicTurn = (correctTurnWeight /
                (totalTurnWeight > 0 ? totalTurnWeight : 1.0)) >=
            0.5;

        print(isMonotonicTurn
            ? (turnType == TURN_TYPE_RIGHT ? "--->" : "<---")
            : ".");

        double dist = Geolocator.distanceBetween(
            smoothedCurrentLocation!.latitude,
            smoothedCurrentLocation!.longitude,
            newLoc.latitude,
            newLoc.longitude);

        double factor =
            pow(cos(radians(deltaBearing)).abs(), DELTA_ANGLE_COS_POW_FACTOR)
                .toDouble();

        double adjDistance = dist * factor;

        smoothedPreviousLocation = smoothedCurrentLocation;

        smoothedCurrentLocation = endPointWithBearing(
            smoothedCurrentLocation!,
            isMonotonicTurn ? actualBearing : smoothedBearing,
            isMonotonicTurn ? dist : adjDistance);
      }

      arrAngleIndex = (arrAngleIndex + 1) % LOCATIONS_SMOOTHING_WINDOW;
    }

    const coords = [
      [9.017973, 38.677511, "A"],
      [9.018341, 38.677511, "B"],
      [9.018778, 38.677511, "C"],
      [9.019189, 38.677511, "D"],
      [9.019575, 38.677511, "E"],
      [9.019970, 38.677511, "F"],
      [9.020383, 38.677511, "G"],
      [9.020728, 38.677736, "H"],
      [9.020948, 38.678101, "I"],
      [9.020948, 38.678495, "J"],
      [9.020948, 38.678908, "K"],
      [9.020948, 38.679313, "L"],
      [9.020948, 38.679726, "M"],
      [9.020948, 38.680150, "N"],
      [9.020948, 38.680260, "O"],
      [9.020948, 38.680395, "P"],
      [9.020948, 38.680503, "Q"],
      [9.020948, 38.680642, "R"],
      [9.020948, 38.680740, "S"],
      [9.020948, 38.680772, "T"],
      [9.020946, 38.680771, "U"],
      [9.020909, 38.680771, "V"],
      [9.020849, 38.680772, "W"],
      [9.020785, 38.680773, "X"],
      [9.020749, 38.680773, "Y"],
      [9.020606, 38.680795, "X"],
      [9.020468, 38.680784, "X"],
      [9.020383, 38.680784, "X"],
      [9.020298, 38.680795, "X"],
      [9.020269, 38.680822, "X"],
      [9.020161, 38.680832, "X"],
      [9.020047, 38.680816, "X"],
      /*
      [9.019900, 38.680858, "X"],
      [9.019794, 38.680804, "X"],
      [9.019848, 38.680791, "X"],
       */
      [9.019811, 38.680859, "X"],
      [9.019721, 38.680790, "X"],
      [9.019632, 38.680880, "X"],
      [9.019542, 38.680796, "X"],
      [9.019442, 38.680865, "X"],
      [9.019445, 38.680924, "X"],
      [9.019446, 38.681002, "X"],
      [9.019450, 38.681087, "X"],
      [9.019452, 38.681169, "X"],
      [9.019452, 38.681295, "X"],
      [9.019578, 38.681324, "X"],
      [9.019743, 38.681273, "X"],
      [9.019767, 38.681328, "X"],
      [9.019864, 38.681274, "X"],
      [9.019971, 38.681317, "X"],
      [9.020281, 38.681328, "X"],
      [9.020588, 38.681308, "X"],
      [9.021305, 38.681225, "X"],
      [9.021221, 38.679737, "X"],
      [9.021207, 38.678568, "X"],
      [9.021184, 38.678028, "X"],
      [9.021393, 38.677944, "X"],
      [9.021588, 38.677718, "X"],
      [9.021629, 38.677282, "X"],
      [9.021495, 38.677108, "X"],
      [9.021263, 38.676925, "X"],
      [9.020925, 38.676887, "X"],
      [9.020768, 38.676956, "X"],
      [9.020642, 38.676845, "X"],
      [9.020492, 38.676787, "X"],
      [9.020212, 38.676751, "X"],
      [9.019896, 38.676726, "X"],
      [9.019797, 38.676658, "X"],
      [9.019794, 38.676391, "X"],
      [9.019792, 38.676124, "X"],
      [9.019799, 38.675907, "X"],
      [9.019931, 38.675894, "X"],
      [9.020045, 38.675893, "X"],
      [9.020029, 38.676081, "X"],
      [9.020024, 38.676343, "X"],
    ];

    String actual = "", smoothed = "";
    for (int i = 0; i < coords.length; i++) {
      computeSmoothedLocation(
          LatLng(coords[i][0] as double, coords[i][1] as double));

      actual = appendLocationToPolyline(
          actual, LatLng(coords[i][0] as double, coords[i][1] as double));

      smoothed = appendLocationToPolyline(smoothed, smoothedCurrentLocation!);
    }

    print('>>>>>>>>>> actual: $actual, smoothed: $smoothed');
  });
}
