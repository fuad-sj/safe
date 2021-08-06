import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
import 'package:safe/models/google_place_description.dart';
import 'package:safe/utils/google_api_util.dart';
import 'package:safe/pickup_and_dropoff_locations.dart';
import 'package:safe/models/address.dart';

class SearchScreen extends StatefulWidget {
  static const String RESPONSE_OBTAINED_DIRECTION =
      'response_obtained_direction';

  const SearchScreen();

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _pickupTextController = TextEditingController();
  TextEditingController _dropOffTextController = TextEditingController();

  List<GooglePlaceDescription>? _placePredictionList;

  @override
  Widget build(BuildContext context) {
    String placeAddress = Provider.of<PickUpAndDropOffLocations>(context)
            .pickUpLocation
            ?.placeName ??
        '';

    _pickupTextController.text = placeAddress;

    return Scaffold(
      body: Column(
        children: [
          // Pickup and DropOff container(top section)
          Container(
            height: 215.0,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                )
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
              child: Column(
                children: [
                  // Header(Title + Back Button)
                  SizedBox(height: 10.0),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // return back to mainScreen
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back),
                      ),
                      Center(
                        child: Text('Set Drop Off',
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "Brand-Bold")),
                      )
                    ],
                  ),

                  // Pickup Location
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Image.asset('images/pickicon.png',
                          height: 16.0, width: 16.0),
                      SizedBox(width: 18.0),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: IgnorePointer(
                              ignoring: true,
                              child: TextField(
                                controller: _pickupTextController,
                                decoration: InputDecoration(
                                  hintText: 'Pickup Location',
                                  fillColor: Colors.grey.shade400,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 11.0, top: 8.0, bottom: 8.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Dropoff Location
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      Image.asset('images/desticon.png',
                          height: 16.0, width: 16.0),
                      SizedBox(width: 18.0),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              controller: _dropOffTextController,
                              onChanged: (searchPlace) async {
                                searchPlace = searchPlace.trim();
                                if (searchPlace.isEmpty) {
                                  _placePredictionList = null;
                                } else {
                                  _placePredictionList = await GoogleApiUtils
                                      .searchForBestMatchingPlace(searchPlace);
                                }

                                setState(() {});
                              },
                              decoration: InputDecoration(
                                hintText: 'Where to?',
                                fillColor: Colors.grey.shade400,
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 11.0, top: 8.0, bottom: 8.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Search Results
          SizedBox(height: 10.0),
          _placePredictionList == null
              ? Container()
              : Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.all(0.0),
                    separatorBuilder: (_, __) => Divider(
                        height: 1.0, color: Colors.black, thickness: 1.0),
                    itemCount: _placePredictionList?.length ?? 0,
                    itemBuilder: (c, i) {
                      return _SearchedPlaceTile(
                        clickCallback: (place) async {
                          showDialog(
                              context: context,
                              builder: (_) => CustomProgressDialog(
                                  message: 'Setting Dropoff, Please wait...'));

                          Address? address =
                              await GoogleApiUtils.getPlaceAddressDetails(
                                  place.place_id);
                          Navigator.pop(context);

                          if (address == null) {
                            // TODO: show error
                            return;
                          }

                          Provider.of<PickUpAndDropOffLocations>(context,
                                  listen: false)
                              .updateDropOffLocationAddress(address);

                          // dismiss this Search Screen because we've got location
                          Navigator.pop(context,
                              SearchScreen.RESPONSE_OBTAINED_DIRECTION);
                        },
                        place: _placePredictionList![i],
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class _SearchedPlaceTile extends StatelessWidget {
  final GooglePlaceDescription place;
  final Function(GooglePlaceDescription) clickCallback;

  _SearchedPlaceTile({
    required this.place,
    required this.clickCallback,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => clickCallback(place),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(Icons.add_location),
          SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.0),
                Text(
                  place.main_name,
                  // prevent overflow
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 2.0),
                Text(
                  place.detailed_name,
                  // prevent overflow
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
