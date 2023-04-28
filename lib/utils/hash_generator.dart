
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HashGenerator {
  static const BASE32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  static String hashForLocation({required LatLng location, precision = 10}) {
    List<double> latRange = [-90, 90];
    List<double> longRange = [-180, 180];

    String hash = '';
    int hashValue = 0;
    int numBits = 0;
    bool isEven = true;

    while (hash.length < precision) {
      double val = isEven ? location.longitude : location.latitude;
      List<double> range = isEven ? longRange : latRange;
      double mid = (range[0] + range[1]) / 2;

      if (val > mid) {
        hashValue = (hashValue << 1) + 1;
        range[0] = mid;
      } else {
        hashValue = (hashValue << 1) + 0;
        range[1] = mid;
      }

      isEven = !isEven;

      if (numBits < 4) {
        numBits++;
      } else {
        numBits = 0;
        hash += BASE32[hashValue];
        hashValue = 0;
      }
    }

    return hash;
  }
}