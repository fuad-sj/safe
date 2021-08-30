import 'package:flutter/widgets.dart';
import 'package:safe/models/address.dart';

class PickUpAndDropOffLocations extends ChangeNotifier {
  Address? pickUpLocation;
  Address? dropOffLocation;
  bool? isStudent;

  void updatePickupLocationAddress(Address address) {
    pickUpLocation = address;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address address) {
    dropOffLocation = address;
    notifyListeners();
  }

  void setIsStudent(bool is_student) {
    isStudent = is_student;
    notifyListeners();
  }
}
