import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safe/driver_location/compass_ui.dart';

import '../utils/map_style.dart';

class WayToDriverCompassScreen extends StatefulWidget {
  const WayToDriverCompassScreen({Key? key}) : super(key: key);

  @override
  State<WayToDriverCompassScreen> createState() =>
      _WayToDriverCompassScreenState();
}

class _WayToDriverCompassScreenState extends State<WayToDriverCompassScreen> {
  static const CameraPosition ADDIS_ABABA_CENTER_LOCATION = CameraPosition(
      target: LatLng(9.00464643580664, 38.767820855962), zoom: 17.0);

  Set<Polyline> _mapPolyLines = Set();
  Set<Marker> _mapMarkers = Set();

  GoogleMapController? _mapController;

  double left_n_rgt = 0.0;

  bool isLeftTrue = false;

  static const double DEFAULT_SEARCH_RADIUS = 3.0;

  @override
  Widget build(BuildContext context) {
    const double TOP_MAP_PADDING = 40;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(
              top: TOP_MAP_PADDING,
              bottom: 0,
            ),
            polylines: _mapPolyLines,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: ADDIS_ABABA_CENTER_LOCATION,
            myLocationEnabled: false,
            zoomGesturesEnabled: false,
            zoomControlsEnabled: false,
            markers: _mapMarkers,
            onMapCreated: (GoogleMapController controller) async {
              _mapController = controller;
              controller.setMapStyle(GoogleMapStyle.mapStyles);

              setState(() {
                // once location is acquired, add a bottom padding to the map
              });
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                end: Alignment.bottomRight,
                begin: Alignment.topRight,
                colors: [
                  Color(0xCFD30808),
                  Color(0xdddc0000),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.025,
                  left: MediaQuery.of(context).size.width * 0.070,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios_new),
                    iconSize: 28.0,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.1,
                  left: MediaQuery.of(context).size.width * 0.082,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.078,
                    width: MediaQuery.of(context).size.width * 0.82,
                    child: Row(
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FINDING',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                "SAFE'S DRIVER",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Image(image: AssetImage('images/safe_gray.png')),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.384,
                  left: MediaQuery.of(context).size.width * 0.082,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.60,
                  child: SmoothCompass(
                    compassBuilder: (context, snapshot, child) {
                      left_n_rgt = double.parse(snapshot?.data?.angle.toStringAsFixed(2) ?? '0');

                      if (left_n_rgt <= 180) {
                        isLeftTrue = true;
                      }

                      return Container(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.19,
                              child: Center(
                                child: AnimatedRotation(
                                  turns: snapshot?.data?.turns ?? 0,
                                  duration: Duration(milliseconds: 400),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.30,
                                    height: MediaQuery.of(context).size.height *
                                        0.10,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              "images/new_arrow.png"),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.19),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.82,
                              child: Row(
                                children: [
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "15 m",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 41,
                                              fontFamily: 'Lato',
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                           isLeftTrue! ? 'to your Left ' : 'to your right',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
