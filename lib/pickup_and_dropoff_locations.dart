import 'package:flutter/widgets.dart';
import 'package:safe/models/address.dart';

class PickUpAndDropOffLocations extends ChangeNotifier {
  Address? pickUpLocation;
  Address? dropOffLocation;

  void updatePickupLocationAddress(Address address) {
    pickUpLocation = address;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address address) {
    dropOffLocation = address;
    notifyListeners();
  }
}
