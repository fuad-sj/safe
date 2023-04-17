import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safe/driver_location/compass_ui.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import '../models/customer.dart';
import '../utils/map_style.dart';

class SharedRideWhereToGoScreen extends StatefulWidget {
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
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                    Color(0xFFDC0000),
                    Color(0xff8f0909),
                  ])),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios_new_outlined,
                                  color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Selam, Fuad',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Lato",
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: constraints.maxHeight > 130 ? 56 : 0,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 10.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'ወዴት መሄድ ይፈልጋሉ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WayToDriverCompassScreen()),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(
            top: 10.0,
            left: hWidth * 0.076,
            right: hWidth * 0.076,
            bottom: vHeight * 0.02),
        child: Container(
          child: Column(
            children: [
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
                child: Center(
                  child: Text('Bole'),
                ),
              ),
              Container(
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: hWidth * 0.25,
                      child: Image(image: AssetImage('images/car_side.png')
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Text('ባለ 4 መቀመጫ'),
                          Text('65.00 ብር'),
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
