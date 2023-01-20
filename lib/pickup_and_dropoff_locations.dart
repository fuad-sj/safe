import 'package:flutter/widgets.dart';
import 'package:safe/models/address.dart';

class PickUpAndDropOffLocations extends ChangeNotifier {
  Address? pickUpLocation;
  Address? dropOffLocation;
  Duration? scheduledDuration;
  bool? isStudent;
  bool resetPickupLocation = false;

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

  void setIsStudent(bool is_student) {
    isStudent = is_student;
    notifyListeners();
  }

  void setResetPickupLocation(bool reset) {
    resetPickupLocation = reset;
    notifyListeners();
  }
}
