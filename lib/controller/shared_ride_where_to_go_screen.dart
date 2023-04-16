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
            pinned: _pinned,
            snap: _snap,
            floating: _floating,
            expandedHeight: 160.0,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                ('Selam'),
                style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Lato"),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  color: index.isOdd ? Colors.white : Colors.black12,
                  height: 100.0,
                  child: Center(
                    child: Text('$index', textScaleFactor: 5),
                  ),
                );
              },
              childCount: 20,
            ),
          )
        ],
      ),
    );
  }
}
