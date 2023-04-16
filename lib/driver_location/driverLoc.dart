import 'dart:math' show sin, cos, tan, atan;

import 'package:vector_math/vector_math.dart' show radians, degrees;

class Utils {
  Utils._();

  static final _deLa = radians(8.9980347);
  static final _deLo = radians(38.7794029);

  /// returns the qiblah offset for the current location
  static double getOffsetFromNorth(
      double currentLatitude,
      double currentLongitude,
      ) {
    /// converting current lat & lang to radians
    var laRad = radians(currentLatitude);
    var loRad = radians(currentLongitude);

    /// converting current lat & lang to Degrees
    var toDegrees = degrees(atan(sin(_deLo - loRad) /
        ((cos(laRad) * tan(_deLa)) - (sin(laRad) * cos(_deLo - loRad)))));
    if (laRad > _deLa) {
      if ((loRad > _deLo || loRad < radians(-180.0) + _deLo) &&
          toDegrees > 0.0 &&
          toDegrees <= 90.0) {
        toDegrees += 180.0;
      } else if (loRad <= _deLo &&
          loRad >= radians(-180.0) + _deLo &&
          toDegrees > -90.0 &&
          toDegrees < 0.0) {
        toDegrees += 180.0;
      }
    }

    /// check if the latRadian is less than the destination lat
    if (laRad < _deLa) {
      if ((loRad > _deLo || loRad < radians(-180.0) + _deLo) &&
          toDegrees > 0.0 &&
          toDegrees < 90.0) {
        toDegrees += 180.0;
      }

      /// check if the loRadian is less than or equal to the destination long
      if (loRad <= _deLo &&
          loRad >= radians(-180.0) + _deLo &&
          toDegrees > -90.0 &&
          toDegrees <= 0.0) {
        toDegrees += 180.0;
      }
    }

    /// returns the qiblah direction in degrees
    return toDegrees;
  }
}
