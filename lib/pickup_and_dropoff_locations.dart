import 'package:flutter/widgets.dart';
import 'package:safe/models/address.dart';

class PickUpAndDropOffLocations extends ChangeNotifier {
  Address? pickUpLocation;
  Address? dropOffLocation;
  Duration? scheduledDuration;

  void updatePickupLocationAddress(Address? address) {
    pickUpLocation = address;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address? address) {
    dropOffLocation = address;
    notifyListeners();
  }

  void updateScheduledDuration(Duration? duration) {
    scheduledDuration = duration;
    notifyListeners();
  }
}
