import 'dart:math';

import 'package:safe/models/driver_location.dart';

class DummyDriverGenerator {
  static Map<String, DriverLocation> _driverLocations = {};

  static const double _ADDIS_CENTER_LAT = 9.010297;
  static const double _ADDIS_CENTER_LNG = 38.750483;

  static const double _DX_LNG_DELTA_MAX = 0.078332;
  static const double _DY_LAT_DELTA_MAX = 0.032242;

  static const double _NOISE_SCALE_FACTOR_DX = (1.0 / 300.0);
  static const double _NOISE_SCALE_FACTOR_DY = (1.0 / 150.0);

  static Random _random = Random();

  static Stream<List<DriverLocation>> generateRandomDrivers(
      int numDrivers, int emitMilliseconds) {
    return Stream<List<DriverLocation>>.periodic(
      Duration(milliseconds: emitMilliseconds),
      (count) {
        List<DriverLocation> drivers = [];

        for (int i = 1; i <= numDrivers; i++) {
          String driverID = 'Driver _$i';

          DriverLocation? prevLoc;
          if (_driverLocations.containsKey(driverID)) {
            prevLoc = _driverLocations[driverID];
          }

          DriverLocation location;

          if (prevLoc != null) {
            //double dx = 0;
            //double dy = 0;
            double dx = _NOISE_SCALE_FACTOR_DX * (_random.nextDouble() - 0.13);
            double dy = _NOISE_SCALE_FACTOR_DY * (_random.nextDouble() - 0.7);

            prevLoc.latitude += dy * _DY_LAT_DELTA_MAX;
            prevLoc.longitude += dx * _DX_LNG_DELTA_MAX;

            location = prevLoc;
          } else {
            double jump_factor = _random.nextDouble();

            double dir_x = _random.nextDouble() - 0.5;
            double dir_y = _random.nextDouble() - 0.5;

            location = DriverLocation(
              driverID: driverID,
              latitude:
                  _ADDIS_CENTER_LAT + dir_y * jump_factor * _DY_LAT_DELTA_MAX,
              longitude:
                  _ADDIS_CENTER_LNG + dir_x * jump_factor * _DX_LNG_DELTA_MAX,
            );
          }

          _driverLocations[driverID] = location;
          drivers.add(location);
        }

        return drivers;
      },
    );
  }
}
