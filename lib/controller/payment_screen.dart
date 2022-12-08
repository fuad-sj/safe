import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:safe/GraphView.dart';
import 'dart:ui' as ui;

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final Graph graph = Graph();

  SugiyamaConfiguration builder = SugiyamaConfiguration()
    ..bendPointShape = CurvedBendPointShape(curveLength: 20);
  late int bottomIndex;

  void changeScreenPayment(int? index) {
    setState(() {
      bottomIndex = index!;
    });
  }

  @override
  void initState() {
    super.initState();
    bottomIndex = 0;
    final node1 = Node.Id(1);
    final node2 = Node.Id(2);
    final node3 = Node.Id(3);
    final node4 = Node.Id(4);
    final node5 = Node.Id(5);
    final node6 = Node.Id(6);
    final node8 = Node.Id(7);
    final node7 = Node.Id(8);
    final node9 = Node.Id(9);

    graph.addEdge(node1, node2, paint: Paint()..color = Colors.red);
    graph.addEdge(node1, node3);
    graph.addEdge(node1, node4);
    graph.addEdge(node2, node5);
    graph.addEdge(node2, node6);
    graph.addEdge(node3, node7);
    graph.addEdge(node3, node8);
    graph.addEdge(node5, node9);
    builder
      ..nodeSeparation = (15)
      ..levelSeparation = (15)
      ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  List<_SalesData> data = [
    _SalesData('Sun', 10),
    _SalesData('Mon', 22),
    _SalesData('Thu', 43),
    _SalesData('Wed', 23),
    _SalesData('Thr', 15),
    _SalesData('Fri', 33),
    _SalesData('Sat', 98),
  ];

  List<DateOfEarning> Dates = [
    DateOfEarning('1 D'),
    DateOfEarning('1 W'),
    DateOfEarning('2 W'),
    DateOfEarning('1 M'),
    DateOfEarning('2 M'),
    DateOfEarning('3 M'),
    DateOfEarning('6 M'),
    DateOfEarning('1 Y'),
  ];

  bool showTree = false;
  bool textSelected = false;

  @override
  Widget build(BuildContext context) {
    double vHeight = MediaQuery.of(context).size.height;
    double hWidth = MediaQuery.of(context).size.width;

    TextStyle unSelectedTextFieldStyle() {
      return const TextStyle(
          color: Color.fromRGBO(255, 255, 255, 1),
          fontWeight: FontWeight.w700,
          fontFamily: 'Lato',
          fontSize: 14.0,
          letterSpacing: 1);
    }

    TextStyle selectedTextFieldStyle() {
      return const TextStyle(
          color: Color(0xffDE0000),
          fontWeight: FontWeight.w700,
          fontFamily: 'Lato',
          fontSize: 14.0,
          letterSpacing: 2);
    }

    LinearGradient selectedDateColorGradiant() {
      return const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color(0xffDE0000),
          Color(0xff990000),
        ],
      );
    }

    LinearGradient unSelectedDateColorGradiant() {
      return const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color(0xFCC0BEBE),
          Color(0xff9b9b9b),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Color(0xff1c1c1e),
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.05,
        backgroundColor: Color(0xff1c1c1e),
        elevation: 0.0,
        leading: Transform.translate(
          offset: Offset(10, 1),
          child: new MaterialButton(
            elevation: 6.0,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xffDD0000),
            ),
            color: Color(0xfff0f0f0),
            shape: CircleBorder(),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Payments',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontFamily: 'Lato',
              fontSize: 21.0,
              letterSpacing: 1),
        ),
        actions: <Widget>[],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: vHeight * 0.15,
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.only(left: hWidth * 0.04),
                      width: hWidth * 0.65,
                      height: vHeight * 0.065,
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(70, 70, 70, 1),
                          borderRadius: BorderRadius.circular(50)),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              showTree = false;
                              setState(() {});
                            },
                            child: Container(
                              width: hWidth * 0.25,
                              height: vHeight * 0.045,
                              decoration: !showTree
                                  ? BoxDecoration(
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                      borderRadius: BorderRadius.circular(40),
                                    )
                                  : BoxDecoration(),
                              child: Center(
                                  child: Text(
                                'Earning',
                                style: !showTree
                                    ? selectedTextFieldStyle()
                                    : unSelectedTextFieldStyle(),
                              )),
                            ),
                          ),
                          SizedBox(width: hWidth * 0.01),
                          GestureDetector(
                            onTap: () {
                              showTree = true;
                              setState(() {});
                            },
                            child: Container(
                              width: hWidth * 0.30,
                              height: vHeight * 0.045,
                              decoration: showTree
                                  ? BoxDecoration(
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                      borderRadius: BorderRadius.circular(40),
                                    )
                                  : BoxDecoration(),
                              child: Center(
                                  child: Text(
                                'Your Network',
                                style: showTree
                                    ? selectedTextFieldStyle()
                                    : unSelectedTextFieldStyle(),
                              )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: vHeight * 0.0015,
                    width: hWidth * 0.90,
                    color: Colors.white60,
                  ),
                ),
                Container(
                  width: hWidth * 0.75,
                  padding: EdgeInsets.only(
                      top: vHeight * 0.004, left: hWidth * 0.05),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                    child: Text(
                                      '170.00',
                                      style: TextStyle(
                                          color: Color(0xffffffff),
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1,
                                          fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: hWidth * 0.02,
                                        right: hWidth * 0.02),
                                    child: Text(
                                      '+ 23.00',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w300,
                                          fontSize: 12),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '17 new',
                                      style: TextStyle(
                                          color: Color(0xff9b9b9b),
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 1,
                                          fontSize: 12),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(
                                        left: hWidth * 0.02,
                                        right: hWidth * 0.02),
                                    child: Text(
                                      '+ 2',
                                      style: TextStyle(
                                          color: Color(0xff9b9b9b),
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w300,
                                          fontSize: 12),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: vHeight * 0.004),
                              child: Text(
                                'Last Week',
                                style: TextStyle(
                                    color: Color(0xff9b9b9b),
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 1,
                                    fontSize: 14),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: hWidth * 0.0015,
                        color: Colors.white60,
                        height: vHeight * 0.07,
                      ),
                      Container(
                        padding:
                            EdgeInsets.only(left: hWidth * 0.04, bottom: 10.0),
                        child: Column(
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                    child: Text(
                                      '172.00',
                                      style: TextStyle(
                                          color: Color(0xffffffff),
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1,
                                          fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: hWidth * 0.02,
                                        right: hWidth * 0.02),
                                    child: Text(
                                      '+ 2.00',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w300,
                                          fontSize: 12),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '6 new',
                                      style: TextStyle(
                                          color: Color(0xff9b9b9b),
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 1,
                                          fontSize: 12),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(
                                        left: hWidth * 0.02,
                                        right: hWidth * 0.02),
                                    child: Text(
                                      '+ 1 ',
                                      style: TextStyle(
                                          color: Color(0xff9b9b9b),
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w300,
                                          fontSize: 12),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: vHeight * 0.004),
                              child: Text(
                                'This Week',
                                style: TextStyle(
                                    color: Color(0xff9b9b9b),
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 1,
                                    fontSize: 14),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    height: vHeight * 0.0015,
                    width: hWidth * 0.90,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: !showTree ? vHeight * 0.72 : vHeight * 0.0,
            child: !showTree
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: vHeight * 0.03),
                          child: Container(
                            height: vHeight * 0.060,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: Dates.map((dateCount) {
                                return InkWell(
                                  onTap: () {
                                    textSelected = true;
                                    setState(() {});
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: Center(
                                        child: Text(
                                          dateCount.date,
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
                        ),
                        SizedBox(height: vHeight * 0.01),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: EdgeInsets.only(
                                left: hWidth * 0.06, top: vHeight * 0.02),
                            child: Text(
                              'Your Daily Earnings',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Lato',
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 1),
                            ),
                          ),
                        ),
                        SfCartesianChart(
                          primaryXAxis: CategoryAxis(
                            opposedPosition: false
                          ),
                          legend: Legend(isVisible: false),
                          enableAxisAnimation: true,
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <ChartSeries>[
                            SplineAreaSeries<_SalesData, String>(
                                dataSource: data,
                                splineType: SplineType.cardinal,
                                cardinalSplineTension: 0.5,
                                borderColor: Color.fromRGBO(0, 255, 0, 1),
                                onCreateShader: (ShaderDetails details) {
                                  return ui.Gradient.linear(
                                      details.rect.topCenter,
                                      details.rect.bottomCenter, <Color>[
                                    Color.fromRGBO(0, 255, 0, 0.7),
                                    Color.fromRGBO(60, 60, 60, 0.4)
                                  ], <double>[
                                    0.1,
                                    0.9
                                  ]);
                                },
                                xValueMapper: (_SalesData sales, _) =>
                                    sales.year,
                                yValueMapper: (_SalesData sales, _) =>
                                    sales.sales,
                                name: ' Earning ',
                                borderWidth: 4,
                                dataLabelSettings:
                                    const DataLabelSettings(isVisible: false))
                          ],
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: EdgeInsets.only(
                                left: hWidth * 0.06, top: vHeight * 0.02),
                            child: Text(
                              'your Daily new Network',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Lato',
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 1),
                            ),
                          ),
                        ),
                        Container(
                          height: vHeight * 0.08,
                          child: SfCartesianChart(
                            series: <ChartSeries>[
                              HistogramSeries<_SalesData, num>(
                                  dataSource: data,
                                  yValueMapper: (_SalesData sales, _) =>
                                      sales.sales,
                                  binInterval: 20,
                                  borderWidth: 1),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                : Container(),
          ),
          Expanded(
            child: InteractiveViewer(
                constrained: false,
                boundaryMargin: EdgeInsets.all(100),
                minScale: 0.0002,
                maxScale: 10.6,
                child: GraphView(
                  graph: graph,
                  algorithm: SugiyamaAlgorithm(builder),
                  paint: Paint()
                    ..color = Colors.green
                    ..strokeWidth = 1
                    ..style = PaintingStyle.stroke,
                  builder: (Node node) {
                    // I can decide what widget should be shown here based on the id
                    var a = node.key!.value as int?;
                    return rectangleWidget(a);
                  },
                )),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.04,
        child: BubbleBottomBar(
          backgroundColor: Color(0xff1c1c1e),
          opacity: 1.0,
          hasNotch: true,
          fabLocation: BubbleBottomBarFabLocation.end,
          currentIndex: bottomIndex,
          onTap: changeScreenPayment,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          items: <BubbleBottomBarItem>[
            BubbleBottomBarItem(
              showBadge: true,
              badge: Text("5"),
              badgeColor: Colors.green,
              backgroundColor: Color(0xffDE0000),
              icon: Icon(
                Icons.monetization_on,
                color: Colors.white,
              ),
              activeIcon: Icon(
                Icons.monetization_on_outlined,
                color: Colors.white,
              ),
              title: Text(
                "Cash out",
                style: TextStyle(color: Colors.white),
              ),
            ),
            BubbleBottomBarItem(
              backgroundColor: Color(0xffDE0000),
              icon: Icon(
                Icons.send_outlined,
                color: Colors.white,
              ),
              activeIcon: Icon(
                Icons.send_outlined,
                color: Colors.white,
              ),
              title: Text(
                "Send Money To friend",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Random r = Random();

  Widget rectangleWidget(int? a) {
    return Container(
        width: 100,
        height: 50,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.blue[100]!, spreadRadius: 1),
          ],
        ),
        child: Text('Node ${a}'));
  }
}

class DateOfEarning {
  DateOfEarning(this.date);

  final String date;
}

class CustomTotalPriceClipPath extends CustomClipper<Path> {
  var radius = 100.0;

  @override
  Path getClip(Size size) {
    Path path0 = Path();
    path0.moveTo(size.width * 0.001, size.height * 0.200);
    path0.lineTo(size.width * 0.448, size.height * 0.204);
    path0.lineTo(size.width * 0.500, size.height * 0.002);
    path0.lineTo(size.width * 0.55075, size.height * 0.19892);
    path0.lineTo(size.width * 0.999, size.height * 0.200);
    path0.lineTo(size.width * 0.997, size.height * 0.994);
    path0.lineTo(size.width * 0.001, size.height * 0.996);
    path0.lineTo(size.width * 0.001, size.height * 0.200);
    path0.close();

    return path0;
    throw UnimplementedError();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
