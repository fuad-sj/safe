import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/referral_transaction_log.dart';
//import 'package:safe/models/ride_request.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import '../../utils/alpha_numeric_utils.dart';

class TransactionsHistoryScreen extends StatefulWidget {
  const TransactionsHistoryScreen({Key? key}) : super(key: key);

  @override
  _TransactionsHistoryScreenState createState() =>
      _TransactionsHistoryScreenState();
}

class _TransactionsHistoryScreenState extends State<TransactionsHistoryScreen> {
  StreamController<List<ReferralTransactionLog>> _transactionStreamController =
  StreamController<List<ReferralTransactionLog>>.broadcast();

  List<ReferralTransactionLog> _transactions = [];

  @override
  void initState() {
    super.initState();
    _setupRequestStream();
  }

  @override
  void didUpdateWidget(covariant TransactionsHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    _setupRequestStream();
  }

  void _setupRequestStream() async {
    FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_REFERRAL_TRANSACTION_LOG)
        .where(ReferralTransactionLog.TRANS_USER_ID, isEqualTo:FirebaseAuth.instance.currentUser!.uid)
        .orderBy(ReferralTransactionLog.TRANS_TIME_STAMP, descending: true)
        .snapshots()
        .listen((requestSnapshots) {
      if (requestSnapshots.docs.isNotEmpty) {
        var requestTrans = requestSnapshots.docs
            .map((snapshot) => ReferralTransactionLog.fromSnapshot(snapshot))
            .toList();
        _transactionStreamController.add(requestTrans);
      }
    });

    _transactionStreamController.stream
        .listen((List<ReferralTransactionLog> fetchedTransaction) {
      if (mounted) {
        setState(() {
          _transactions = fetchedTransaction;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          ReferralTransactionLog requestTrans = _transactions[index];
          return _TransactionHistoryListItem(
            requestTrans:  requestTrans,
          );
        },
      ),
    );
  }
}

class _TransactionHistoryListItem extends StatefulWidget {
  final ReferralTransactionLog  requestTrans;

  const _TransactionHistoryListItem(
      {Key? key,
        required this.requestTrans,
      })
      : super(key: key);

  @override
  State<_TransactionHistoryListItem> createState() => _TransactionHistoryListItemState();
}

class _TransactionHistoryListItemState
    extends State<_TransactionHistoryListItem> {

    late String _transactionType;
    late Icon _cashInOut;

    Icon cashIn() {
      return const Icon(
        Icons.call_received,
        color: Colors.green,
      );
    }
    Icon cashOut() {
      return const Icon(
        Icons.call_made_outlined,
        color: Colors.redAccent,
      );
    }

  @override
  void initState() {
    super.initState();

    if (widget.requestTrans.trans_type != null ) {
        if (widget.requestTrans.trans_type == 1 ) {
              _transactionType = '5% Cash Back';
              _cashInOut = cashIn();
        }
        else if (widget.requestTrans.trans_type == 2  ) {
          _transactionType = 'Commission Earn';
          _cashInOut = cashIn();
        }
        else if ( widget.requestTrans.trans_type == 3  ) {
          _transactionType = 'Cash Out';
          _cashInOut = cashOut();
        }
        else if ( widget.requestTrans.trans_type == 4  ) {
          _cashInOut = cashOut();
          _transactionType = 'Transfer ';
        }
        else if ( widget.requestTrans.trans_type == 5  ) {
          _cashInOut =  cashIn();
          _transactionType = ' On Rollback Process';
        }
        else if ( widget.requestTrans.trans_type == 6  ) {
          _cashInOut =  cashIn();
          _transactionType = ' Cash Rollback';
        }
        else {
          return;
        }

    }
    else {
        return;
    }

  }

  @override
  Widget build(BuildContext context) {
    FontWeight _bold = FontWeight.bold;

    double vHeight = MediaQuery.of(context).size.height;
    double hWidth = MediaQuery.of(context).size.width;


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

   // _StatusTextTheme statusTheme = getStatusTextTheme(widget.request.ride_status);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
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
                      child: _cashInOut
                    ),
                    SizedBox(width: hWidth * 0.012),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AlphaNumericUtil.formatDouble(widget.requestTrans.trans_amount!, 2)} ' +
                                SafeLocalizations.of(context)!.dialog_trip_summary_birr,
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                fontSize: 20.0,
                                color: Color.fromRGBO(211, 0, 0, 1)
                            ),
                          ),
                          Text(
                             _transactionType, style: mainTextFieldStyle()
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
                                widget.requestTrans.trans_timestamp),
                            style: mainTextFieldStyle(),
                          ),
                          Text(
                            AlphaNumericUtil.formatTimeVersion(
                                widget.requestTrans.trans_timestamp),
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
