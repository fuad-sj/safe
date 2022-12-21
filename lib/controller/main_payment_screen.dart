import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:safe/controller/graphview/GraphView.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui' as ui;

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  final Graph graph = Graph();

  SugiyamaConfiguration builder = SugiyamaConfiguration()
    ..bendPointShape = CurvedBendPointShape(curveLength: 20);

  bool _isNodeClicked = false;

  @override
  void initState() {
    super.initState();
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
    /*
    graph.addEdge(node1, node4);
    graph.addEdge(node2, node5);
    graph.addEdge(node2, node6);
    graph.addEdge(node3, node7);
    graph.addEdge(node3, node8);
    graph.addEdge(node5, node9);
     */
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
    _SalesData('Sat', 28),
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

  @override
  Widget build(BuildContext context) {
    double vHeight = MediaQuery.of(context).size.height;
    double hWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          color: Color(0xff1c1c1e),
          child: Wrap(
            children: [
              Center(
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
                          padding: EdgeInsets.only(left: 5, right: 5.0),
                          width: hWidth * 0.31,
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
              Container(
                height: vHeight * 0.14,
                child: Column(
                  children: [
                    SizedBox(height: vHeight * 0.015),
                    Center(
                      child: Container(
                        height: vHeight * 0.001,
                        width: hWidth * 0.90,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: vHeight * 0.015),
                    Container(
                      height: vHeight * 0.069,
                      padding: EdgeInsets.only(left: hWidth * 0.05),
                      child: Row(
                        children: [
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '170.00',
                                      style: TextStyle(
                                          color: Color(0xfff0f0f0),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Lato',
                                          fontSize: 15.0,
                                          letterSpacing: 2),
                                    ),
                                    SizedBox(width: 4.0),
                                    Text(
                                      '+70.00',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Lato',
                                          fontSize: 10.0,
                                          letterSpacing: 2),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '70 new',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Lato',
                                          fontSize: 12.0,
                                          letterSpacing: 2),
                                    ),
                                    SizedBox(width: 4.0),
                                    Text(
                                      '+2',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Lato',
                                          fontSize: 12.0,
                                          letterSpacing: 2),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Last Week',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Lato',
                                      fontSize: 13.0,
                                      letterSpacing: 2),
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Container(
                            height: vHeight * 0.069,
                            color: Colors.grey,
                            width: hWidth * 0.0015,
                          ),
                          SizedBox(width: 10.0),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '170.00',
                                      style: TextStyle(
                                          color: Color(0xfff0f0f0),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Lato',
                                          fontSize: 15.0,
                                          letterSpacing: 2),
                                    ),
                                    SizedBox(width: 4.0),
                                    Text(
                                      '+70.00',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Lato',
                                          fontSize: 10.0,
                                          letterSpacing: 2),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '70 new',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Lato',
                                          fontSize: 12.0,
                                          letterSpacing: 2),
                                    ),
                                    SizedBox(width: 4.0),
                                    Text(
                                      '+2',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Lato',
                                          fontSize: 12.0,
                                          letterSpacing: 2),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Today',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Lato',
                                      fontSize: 13.0,
                                      letterSpacing: 2),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: vHeight * 0.015),
                    Center(
                      child: Container(
                        height: vHeight * 0.001,
                        width: hWidth * 0.90,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: vHeight * 0.015),
                  ],
                ),
              )
            ],
          ),
        ),
        Container(
          height: !showTree ? vHeight * 0.66 : vHeight * 0.0,
          color: Color(0xff1c1c1e),
          child: !showTree
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
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
                                padding: EdgeInsets.only(left: hWidth * 0.04),
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: Center(
                                    child: Text(
                                      dateCount.date,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
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
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: EdgeInsets.only(left: hWidth * 0.05),
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
                      Container(
                        padding: EdgeInsets.only(left: hWidth * 0.03, right:  hWidth * 0.04 ),
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(opposedPosition: false),
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
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: EdgeInsets.only(left: hWidth * 0.07),
                          child: Text(
                            'Your Daily new Network',
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
                        padding: EdgeInsets.only(left: hWidth * 0.03, right:  hWidth * 0.04 ),
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(
                            majorGridLines: const MajorGridLines(width: 0),
                          ),
                          series: <ChartSeries>[
                            HistogramSeries<_SalesData, num>(
                                dataSource: data,
                                color: Colors.white38,
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
                  return rectangleWidget(a, () {
                    if (!_isNodeClicked) {
                      _isNodeClicked = true;
                      var node1 = Node.Id(1);
                      var node4 = Node.Id(4);
                      graph.addEdge(node1, node4);
                      setState(() {});
                    } else {
                      _isNodeClicked = false;
                      var node1 = Node.Id(4);
                      var node4 = Node.Id(4);
                      graph.removeEdge(Edge(node1, node4));
                      setState(() {});
                    }
                  });
                },
              )),
        ),
      ],
    );
  }

  Random r = Random();

  Widget rectangleWidget(int? a, VoidCallback callback) {
    return GestureDetector(
      onTap: callback,
      child:  Container(
          width: 100,
          height: 50,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: unSelectedDateColorGradiant(),
          ),
          child: Center(child: Text('Node $a',
          style: selectedTextFieldStyle(),
          ))),
    );
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
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
