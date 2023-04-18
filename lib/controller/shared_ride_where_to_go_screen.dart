import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safe/controller/way_to_driver_compass_screen.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import '../models/customer.dart';
import '../utils/map_style.dart';

class SharedRideWhereToGoScreen extends StatefulWidget {
  static const String SHARED_RIDE_DATABASE_ROOT =
      "https://safetransports-et-2995d.firebaseio.com/";

  const SharedRideWhereToGoScreen({Key? key}) : super(key: key);

  @override
  State<SharedRideWhereToGoScreen> createState() =>
      _SharedRideWhereToGoScreenState();
}

class _SharedRideWhereToGoScreenState extends State<SharedRideWhereToGoScreen> {
  bool _pinned = true;
  bool _snap = false;
  bool _floating = false;
  Customer? _currentCustomer;

  bool get _isCustomerActive {
    return _currentCustomer?.is_active ?? false;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: _pinned,
            snap: _snap,
            floating: _floating,
            expandedHeight: 160.0,
            flexibleSpace: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'images/back_pic.png',
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios_new_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'ወዴት መሄድ ይፈልጋሉ ?',
                                    style: TextStyle(
                                      fontSize: 25.0,
                                      color: Color.fromRGBO(255, 255, 255, 1.0),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Nokia Pure Headline Bold",
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(
              height: 15,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return _AvailableDriverListItem();
              },
              childCount: 20,
            ),
          )
        ],
      ),
    );
  }
}

class _AvailableDriverListItem extends StatefulWidget {
  @override
  State<_AvailableDriverListItem> createState() => _AvailableRideListState();
}

class _AvailableRideListState extends State<_AvailableDriverListItem> {
  @override
  Widget build(BuildContext context) {
    double vHeight = MediaQuery.of(context).size.height;
    double hWidth = MediaQuery.of(context).size.width;

    double devicePixelDensity = MediaQuery.of(context).devicePixelRatio;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WayToDriverCompassScreen(
                    selectedRideId: '',
                  )),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: hWidth * 0.014,
          right: hWidth * 0.014,
          bottom: vHeight * 0.01,
        ),
        child: Container(
          decoration: BoxDecoration(
              color: Color.fromRGBO(245, 242, 242, 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 2.0,
                  spreadRadius: 0.0,
                  offset: Offset(2.0, 2.0),
                )
              ]),
          width: hWidth * 0.97,
          child: Column(
            children: [
              Container(
                height: vHeight * 0.050,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                      Color(0xFFDC0000),
                      Color(0xff8f0909),
                    ])),
                child: Center(
                  child: Text('LOCATION',
                      style: TextStyle(
                          fontSize: 45.0 / devicePixelDensity,
                          fontFamily: 'Nokia Pure Headline Bold',
                          color: Color.fromRGBO(255, 255, 255, 1.0))),
                ),
              ),
              Container(
                height: vHeight * 0.090,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Color(0xFFC2C1C1),
                      width: 1.0,
                    ),
                    bottom: BorderSide(
                      color: Color(0xFFC2C1C1),
                      width: 1.0,
                    ),
                    right: BorderSide(
                      color: Color(0xFFC2C1C1),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Container(
                            width: hWidth * 0.135,
                            height: vHeight * 0.035,
                            child:
                                Image(image: AssetImage('images/s_suzuki.png')),
                          ),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'ባለ 4 መቀመጫ',
                                  style: TextStyle(
                                    fontFamily: 'Nokia Pure Headline Bold',
                                    fontSize: 40 / devicePixelDensity,
                                  ),
                                ),
                                Text(
                                  '65.00 ብር',
                                  style: TextStyle(
                                      fontFamily: 'Nokia Pure Headline Bold',
                                      fontSize: 35 / devicePixelDensity,
                                      color: Color.fromRGBO(215, 0, 0, 1.0)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    VerticalDivider(
                      width: 1.0,
                      thickness: 1,
                      endIndent: 0,
                      color: Color.fromRGBO(164, 163, 163, 1.0),
                    ),
                    Container(
                      child: Row(
                        children: [
                          Container(
                            height: vHeight * 0.035,
                            width: hWidth * 0.135,
                            child:
                                Image(image: AssetImage('images/s_avanza.png')),
                          ),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'ባለ 6 መቀመጫ',
                                  style: TextStyle(
                                    fontFamily: 'Nokia Pure Headline Bold',
                                    fontSize: 40 / devicePixelDensity,
                                  ),
                                ),
                                Text(
                                  '45.00 ብር',
                                  style: TextStyle(
                                      fontFamily: 'Nokia Pure Headline Bold',
                                      fontSize: 35 / devicePixelDensity,
                                      color: Color.fromRGBO(215, 0, 0, 1.0)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
