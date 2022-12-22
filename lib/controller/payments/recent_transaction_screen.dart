import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/ride_request.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../../utils/alpha_numeric_utils.dart';

class RecentTransactionsScreen extends StatefulWidget {
  const RecentTransactionsScreen({Key? key}) : super(key: key);

  @override
  _RecentTransactionsScreenState createState() =>
      _RecentTransactionsScreenState();
}

class _RecentTransactionsScreenState extends State<RecentTransactionsScreen> {
  StreamController<List<RideRequest>> _rideRequestsStreamController =
  StreamController<List<RideRequest>>.broadcast();

  List<RideRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _setupRequestStream();
  }

  @override
  void didUpdateWidget(covariant RecentTransactionsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    _setupRequestStream();
  }

  void _setupRequestStream() async {
    FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(FIRESTORE_PATHS.SUB_COL_CUSTOMERS_RIDE_HISTORY)
        .orderBy(RideRequest.FIELD_DATE_RIDE_CREATED, descending: true)
        .snapshots()
        .listen((requestSnapshots) {
      if (requestSnapshots.docs.isNotEmpty) {
        var requests = requestSnapshots.docs
            .map((snapshot) => RideRequest.fromSnapshot(snapshot))
            .toList();
        _rideRequestsStreamController.add(requests);
      }
    });

    _rideRequestsStreamController.stream
        .listen((List<RideRequest> fetchedRides) {
      if (mounted) {
        setState(() {
          _requests = fetchedRides;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          RideRequest request = _requests[index];
          return _TransactionHistoryListItem(
            request: request,
          );
        },
      ),
    );
  }
}
class _StatusTextTheme {
  Color colorTxt;
  _StatusTextTheme({required this.colorTxt});
}

class _TransactionHistoryListItem extends StatefulWidget {
  final RideRequest request;

  const _TransactionHistoryListItem(
      {Key? key,
        required this.request,
      })
      : super(key: key);

  @override
  State<_TransactionHistoryListItem> createState() => _TransactionHistoryListItemState();
}

class _TransactionHistoryListItemState
    extends State<_TransactionHistoryListItem> {
  late String _driverName;
  late String _carType;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FontWeight _bold = FontWeight.bold;

    double vHeight = MediaQuery.of(context).size.height;
    double hWidth = MediaQuery.of(context).size.width;

    _StatusTextTheme getStatusTextTheme(int requestStatus) {
      Color txtColor;

      if (requestStatus == RideRequest.STATUS_TRIP_COMPLETED) {
        txtColor = Colors.blue.shade900;
      } else if (RideRequest.isRideRequestCancelled(requestStatus)) {

        txtColor = Colors.blue.shade900;
      } else {
        txtColor = Colors.blue.shade900;
      }

      return _StatusTextTheme(colorTxt: txtColor);
    }

    TextStyle mainTextFieldStyle() {
      return const TextStyle(
        color: Color.fromRGBO(43, 47, 45, 1),
        fontWeight: FontWeight.w500,
        fontFamily: 'Lato',
        fontSize: 14.0,
      );
    }

    TextStyle secondTextFieldStyle() {
      return const TextStyle(
        color: Color.fromRGBO(144, 145, 144, 1),
        fontWeight: FontWeight.w300,
        fontFamily: 'Lato',
        fontSize: 12.0,
      );
    }

    _StatusTextTheme statusTheme =
    getStatusTextTheme(widget.request.ride_status);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.request.ride_status == RideRequest.STATUS_TRIP_COMPLETED) {
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
            top: 5.0,
            left: hWidth * 0.055,
            right: hWidth * 0.055,
            bottom: vHeight * 0.01),
        child: Container(
          padding: EdgeInsets.only(
              top: vHeight * 0.021,
              bottom: vHeight * 0.032),
          decoration: BoxDecoration(
              color: Color(0xffF6F6F6),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(1, 2))
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(width: hWidth * 0.018),
                    Container(
                      child: Icon(
                        Icons.outbond,
                        color: Colors.redAccent,
                      ),
                    ),
                    SizedBox(width: hWidth * 0.012),
                    Container(
                      child: Column(
                        children: [
                          Text(
                            '150 ETB',
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                fontSize: 20.0,
                                color: Color.fromRGBO(211, 0, 0, 1)
                            ),
                          ),
                          Text(
                              'Cashed Out', style: mainTextFieldStyle()
                          )
                        ],
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.only(right: hWidth * 0.033),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AlphaNumericUtil.formatDate(
                                widget.request.date_ride_created),
                            style: mainTextFieldStyle(),
                          ),
                          Text(
                            AlphaNumericUtil.formatTimeVersion(
                                widget.request.date_ride_created),
                            style: secondTextFieldStyle(),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
