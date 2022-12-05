import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:safe/GraphView.dart';


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
    final node10 = Node.Id(10);
    final node11 = Node.Id(11);
    final node12 = Node.Id(12);
    final node13 = Node.Id(13);
    final node14 = Node.Id(14);
    final node15 = Node.Id(15);
    final node16 = Node.Id(16);
    final node17 = Node.Id(17);
    final node18 = Node.Id(18);
    final node19 = Node.Id(19);
    final node20 = Node.Id(20);
    final node21 = Node.Id(21);
    final node22 = Node.Id(22);
    final node23 = Node.Id(23);

    graph.addEdge(node1, node13, paint: Paint()..color = Colors.red);
    graph.addEdge(node1, node21);
    graph.addEdge(node1, node4);
    graph.addEdge(node1, node3);
    graph.addEdge(node2, node3);
    graph.addEdge(node2, node20);
    graph.addEdge(node3, node4);
    graph.addEdge(node3, node5);
    graph.addEdge(node3, node23);
    graph.addEdge(node4, node6);
    graph.addEdge(node5, node7);
    graph.addEdge(node6, node8);
    graph.addEdge(node6, node16);
    graph.addEdge(node6, node23);
    graph.addEdge(node7, node9);
    graph.addEdge(node8, node10);
    graph.addEdge(node8, node11);
    graph.addEdge(node9, node12);
    graph.addEdge(node10, node13);
    graph.addEdge(node10, node14);
    graph.addEdge(node10, node15);
    graph.addEdge(node11, node15);
    graph.addEdge(node11, node16);
    graph.addEdge(node12, node20);
    graph.addEdge(node13, node17);
    graph.addEdge(node14, node17);
    graph.addEdge(node14, node18);
    graph.addEdge(node16, node18);
    graph.addEdge(node16, node19);
    graph.addEdge(node16, node20);
    graph.addEdge(node18, node21);
    graph.addEdge(node19, node22);
    graph.addEdge(node21, node23);
    graph.addEdge(node22, node23);
    graph.addEdge(node1, node22);
    graph.addEdge(node7, node8);

    builder
      ..nodeSeparation = (15)
      ..levelSeparation = (15)
      ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  List<_SalesData> data = [
    _SalesData('Mon', 05),
    _SalesData('Tus', 18),
    _SalesData('Wen', 24),
    _SalesData('Thr', 15),
    _SalesData('Fri', 25),
    _SalesData('Sat', 25),
    _SalesData('Sun', 30)
  ];

  bool showTree = false;

  @override
  Widget build(BuildContext context) {

    double vHeight = MediaQuery.of(context).size.height;
    double hWidth = MediaQuery.of(context).size.width;

    TextStyle unSelectedTextFieldStyle() {
      return const TextStyle(
          color: Color.fromRGBO(0, 0, 0, 0.5),
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
          letterSpacing: 1);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Color(0xffffffff),
        elevation: 0.0,
        leading: Transform.translate(
          offset: Offset(10, 1),
          child: new MaterialButton(
            elevation: 4.0,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xffDD0000),
            ),
            color: Color(0xffffffff),
            shape: CircleBorder(),
          ),
        ),
        centerTitle: true,
        title: Text(
          'this is the text',
          style: TextStyle(
              color: Colors.black,
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
          Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.only(left: hWidth * 0.04),
                    width: hWidth * 0.65,
                    height: vHeight * 0.055,
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(234, 234, 234, 1),
                        borderRadius: BorderRadius.circular(40)),
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
            ],
          ),

          Container(
            child: !showTree
                ? Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: vHeight * 0.03),
                  child: Container(
                    height: vHeight * 0.040,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: Container(
                            padding:
                            EdgeInsets.symmetric(horizontal: 20.0),
                            decoration: BoxDecoration(
                                gradient: unSelectedDateColorGradiant(),
                                borderRadius:
                                BorderRadius.circular(10.0)),
                            child: Center(
                              child: Text(
                                '10 - 11 - 12',
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: Container(
                            padding:
                            EdgeInsets.symmetric(horizontal: 20.0),
                            decoration: BoxDecoration(
                                gradient: selectedDateColorGradiant(),
                                borderRadius:
                                BorderRadius.circular(10.0)),
                            child: Center(
                              child: Text(
                                '10 - 11 - 12',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: Container(
                            padding:
                            EdgeInsets.symmetric(horizontal: 20.0),
                            decoration: BoxDecoration(
                                gradient: unSelectedDateColorGradiant(),
                                borderRadius:
                                BorderRadius.circular(10.0)),
                            child: Center(
                              child: Text(
                                '10 - 11 - 12',
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: Container(
                            padding:
                            EdgeInsets.symmetric(horizontal: 20.0),
                            decoration: BoxDecoration(
                                gradient: unSelectedDateColorGradiant(),
                                borderRadius:
                                BorderRadius.circular(10.0)),
                            child: Center(
                              child: Text(
                                '10 - 11 - 12',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: vHeight * 0.01),
                Center(
                  child: Stack(
                    children: [
                      ClipPath(
                        child: Container(
                          width: hWidth * 0.45,
                          height: vHeight * 0.09,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.black12,
                          ),
                          padding: EdgeInsets.only(
                              top: 20, left: 20, right: 10),
                          child: Row(
                            children: [
                              Container(
                                child: Column(
                                  children: [
                                    Text(
                                      '184',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Lato',
                                          fontSize: 16,
                                          letterSpacing: 2,
                                          color: Color(0xffdd0000)),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'ETB',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Lato',
                                          letterSpacing: 2,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    )
                                  ],
                                ),
                              ),
                              Spacer(),
                              Container(
                                child: Column(
                                  children: [
                                    Text(
                                      'Your Bonus',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Lato',
                                          letterSpacing: 2,
                                          color: Color(0xff909190)),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      '75 ETB',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Lato',
                                          letterSpacing: 2,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        clipper: CustomTotalPriceClipPath(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: vHeight * 0.04),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: EdgeInsets.only(
                        left: hWidth * 0.06, top: vHeight * 0.03),
                    child: Text(
                      'Your Daily Earnings',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Lato',
                          fontSize: 16,
                          letterSpacing: 1),
                    ),
                  ),
                ),
                SizedBox(height: vHeight * 0.04),
                SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    legend: Legend(isVisible: false),
                    palette: const [
                      Color.fromRGBO(222, 0, 0, 1.0),
                    ],
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries<_SalesData, String>>[
                      LineSeries<_SalesData, String>(
                          dataSource: data,
                          xValueMapper: (_SalesData sales, _) =>
                          sales.year,
                          yValueMapper: (_SalesData sales, _) =>
                          sales.sales,
                          name: ' Earning ',
                          dataLabelSettings:
                          const DataLabelSettings(isVisible: true))
                    ])
              ],
            )
                : Container(),
          ),

          Expanded(
            child: InteractiveViewer(
                constrained: false,
                boundaryMargin: EdgeInsets.all(100),
                minScale: 0.0001,
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
        height: MediaQuery.of(context).size.height * 0.055,
        child: BubbleBottomBar(
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
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.monetization_on_outlined,
                color: Colors.black,
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
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.send_outlined,
                color: Colors.black,
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
