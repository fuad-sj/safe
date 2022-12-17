import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

class cashOutDialog extends StatefulWidget {
  const cashOutDialog({Key? key}) : super(key: key);

  @override
  _cashOutDialogState createState() => _cashOutDialogState();
}

class _cashOutDialogState extends State<cashOutDialog> {
  @override
  void initState() {
    super.initState();
  }

  List<AmountToCashOut> amounts = [
    AmountToCashOut('100'),
    AmountToCashOut('150'),
    AmountToCashOut('200'),
    AmountToCashOut('250'),
    AmountToCashOut('300'),
    AmountToCashOut('500'),
    AmountToCashOut('1000'),
    AmountToCashOut('1500'),
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double HORIZONTAL_PADDING = 15.0;

    return Dialog(
      elevation: 2.0,
      insetPadding: EdgeInsets.symmetric(horizontal: 10.0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dialog Header
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xffDE0000),
                    Color(0xff990000),
                  ],
                ),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  child: Text(
                    "CASH OUT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 35.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
            width: (screenWidth - 2 * HORIZONTAL_PADDING),
            child: Center(
              child: Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'AMOUNT',
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                              fontSize: 20.0),
                        ),
                        SizedBox(width: 20.0),
                        Container(
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(34, 34, 34, 0.2),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          width: MediaQuery.of(context).size.width * 0.5,
                          padding: EdgeInsets.only(right: 30.0),
                          child: TextField(
                            style: TextStyle(color: Colors.black, fontSize: 20),
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10.0),
                                hintText: '200',
                                hintStyle: TextStyle(color: Colors.grey),
                                fillColor: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 35.0),
          Container(
            height: MediaQuery.of(context).size.height * 0.040,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: amounts.map((amountCount) {
                return InkWell(
                  onTap: () {
                    setState(() {});
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 10, left: 20),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            Color(0xffDE0000),
                            Color(0xff990000),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          amountCount.amount,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontFamily: 'Lato',
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20.0),

          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xffffffff),
                    Color(0xffffffff),
                  ],
                ),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0))),
            child: Center(
              child: TextButton(
                onPressed: () async {},
                child: Text(
                  'Send',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 28.0,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          // Done Trip
        ],
      ),
    );
  }
}

class AmountToCashOut {
  AmountToCashOut(this.amount);

  final String amount;
}
