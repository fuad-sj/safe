import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class AlphaNumericUtil {
  static String toTitleCase(String str) {
    return str;
  }

  static final _doubleFormatter = [
    NumberFormat("#,###"),
    NumberFormat("#,###.#"),
    NumberFormat("#,###.##"),
    NumberFormat("#,###.###"),
    NumberFormat("#,###.####"),
  ];

  static String formatDouble(double d, int digits) {
    return _doubleFormatter[min(digits, _doubleFormatter.length)].format(d);
  }

  static final _dateFormatter = DateFormat('dd/MM/yyyy');
  static final _longDateFormatter = DateFormat('dd-MM-yyyy hh:mm');
  static final _timeFormatter = DateFormat('hh:mm');

  static String formatDate(DateTime? date) {
    return date == null ? "" : _dateFormatter.format(date);
  }

  static String formatDateLongVersion(DateTime? date) {
    return date == null ? "" : _longDateFormatter.format(date);
  }

  static String formatTimeVersion(DateTime? date) {
    return date == null ? "" : _timeFormatter.format(date);
  }

  static double parseDouble(String val) {
    try {
      String clean = val.replaceAll(',', '');
      return double.parse(clean);
    } catch (e) {
      return 0;
    }
  }

  static int parseInt(String val, int defaultVal) {
    try {
      return int.tryParse(val) ?? defaultVal;
    } catch (e) {
      return 0;
    }
  }

  static String formatDuration(Duration duration) {
    return duration.toString().split('.').first.padLeft(8, "0");
  }

  static String extractFileExtensionFromName(String filename) {
    int lastIndex = filename.lastIndexOf(".");
    return filename.substring(lastIndex);
  }

  static Future<BitmapDescriptor?> getBytesFromAsset(
      BuildContext context, String path, double sizeRatio) async {
    double screenWidth = MediaQuery.of(context).size.width;
    int iconSize = (screenWidth * sizeRatio).toInt();
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: iconSize);
    FrameInfo fi = await codec.getNextFrame();
    Uint8List? iconData =
        (await fi.image.toByteData(format: ImageByteFormat.png))
            ?.buffer
            .asUint8List();
    if (iconData == null) return null;
    return BitmapDescriptor.fromBytes(iconData);
  }
}
