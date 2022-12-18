import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';

class sendMoneyDialog extends StatefulWidget {
  const sendMoneyDialog({Key? key}) : super(key: key);

  @override
  _sendMoneyDialogState createState() => _sendMoneyDialogState();
}

class _sendMoneyDialogState extends State<sendMoneyDialog> {

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
    double screenHeight = MediaQuery.of(context).size.height;
    double edgePadding = screenWidth * 0.10 / 2.0; // 10% of screen width

    double HORIZONTAL_PADDING = 15.0;

    return Dialog(
      elevation: 2.0,
      insetPadding: EdgeInsets.symmetric(horizontal: screenHeight * 0.034),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dialog Header
          Container(
            height: screenHeight * 0.086,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(left: screenWidth * 0.044),

                  child: GestureDetector(
                    onTap:() {
                      Navigator.pop(context, true);
                    },
                    child: Icon(
                      Icons.close,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),
                ),
                Spacer(flex: 1),
                Container(
                  padding: EdgeInsets.only(left: screenWidth * 0.044),
                  child: Text(
                    "Send Money",
                    style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
                  ),
                ),
                Spacer(flex: 2),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.045),

          Center(
            child: Container(
              width: screenWidth * 0.70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            'Phone',
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                color: Color.fromRGBO(43, 47, 45, 1)),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.050),
                        Container(
                          child: Text(
                            'Amount',
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                color: Color.fromRGBO(43, 47, 45, 1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.025),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(225, 224, 223, 1),
                            borderRadius: BorderRadius.all(
                              Radius.circular(15.0),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: screenWidth * 0.025),
                              Expanded(
                                child: SizedBox(
                                  height: screenHeight * 0.045,
                                  child: TextField(
                                    expands: true,
                                    maxLines: null,
                                    minLines: null,
                                    style: TextStyle(color: Colors.black, fontSize: 12),
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '+251912345678',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      fillColor: Colors.black,
                                      contentPadding: const  EdgeInsets.symmetric(
                                          horizontal: 5.0,
                                          vertical: 10.0
                                      )

                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.025),

                        Container(
                          height: screenHeight * 0.045,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(225, 224, 223, 1),
                            borderRadius: BorderRadius.all(
                              Radius.circular(15.0),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: screenWidth * 0.025),
                              Expanded(
                                child: TextField(
                                  expands: true,
                                  maxLines: null,
                                  minLines: null,
                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '200',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      fillColor: Colors.black,
                                      contentPadding: const  EdgeInsets.symmetric(
                                          horizontal: 5.0,
                                          vertical: 10.0
                                      ),
                                  ),
                                ),
                              ),
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
          SizedBox(height: screenHeight * 0.040),
          Container(
            height: screenHeight * 0.040,
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
                        borderRadius: BorderRadius.circular(15.0),
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
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
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
          SizedBox(height: screenHeight * 0.040),


          Center(
            child: Container(
              height: screenHeight * 0.04 ,
              width: screenWidth * 0.26,
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
                  'Send',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lato',
                      letterSpacing: 1
                  ),
                ),
              ),
            ),
          ),
          // Done Trip
          SizedBox(height: screenHeight * 0.040),
        ],
      ),
    );
  }
}

class AmountToCashOut {
  AmountToCashOut(this.amount);

  final String amount;
}
