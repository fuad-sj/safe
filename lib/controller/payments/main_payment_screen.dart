import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:safe/controller/graphview/GraphView.dart';
import 'package:safe/models/referral_current_balance.dart';
import 'package:safe/models/referral_daily_earnings.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/models/referral_traversed_tree.dart';
import 'package:safe/utils/pref_util.dart';
import 'package:safe/controller/graphview/GraphView.dart';

class MainPaymentScreen extends StatefulWidget {
  const MainPaymentScreen({Key? key}) : super(key: key);

  @override
  _MainPaymentScreenState createState() => _MainPaymentScreenState();
}

class NodePair {
  SubTreeNode treeNode;
  Node graphNode;

  NodePair(this.treeNode, this.graphNode);
}

class _MainPaymentScreenState extends State<MainPaymentScreen> {
  final Graph graph = Graph();

  SugiyamaConfiguration builder = SugiyamaConfiguration()
    ..bendPointShape = CurvedBendPointShape(curveLength: 50);

  bool graphMode = false;

  ReferralTraversedTree? _traversedTree;

  String? _rootNodeId;
  NodePair? _rootNodeInfo; // useful for resetting the graph

  Map<String, NodePair> _mapNodes = Map();
  Map<String, Set<String>> _nodeDirectChildren = Map();
  bool graphLoadFinished = false;
  Set<String> _nodesUpdatedDirectChildren = Set();
  Set<String> _initiallyCachedNodes = Set();
  Map<String, NodePair> _removedNodes = Map();
  List<ReferralDailyEarnings> _dailyEarnings = [];

  StreamSubscription? _liveCurrentBalanceStream;
  StreamSubscription? _liveTotalChildrenStream;
  StreamSubscription? _liveDateRangeEarningsStream;

  ReferralCurrentBalance? _currentBalance;
  Customer? _currentCustomerInfo;
  double _dateRangeTotalEarnings = 0;
  double _prevDateRangeTotalEarnings = 0;

  double? _lastReadCurrentBalance;
  int? _lastReadTotalChildren;

  bool isIncomeIncreasing = true; // if it decreases, use a red line
  int selectedDateRange = 0; // default is 1 Week
  final DATE_RANGES = [
    DateWindow('1 W', 8),
    DateWindow('2 W', 15),
    DateWindow('1 M', 30),
    DateWindow('3 M', 90),
    DateWindow('6 M', 180),
    DateWindow('1 Y', 360),
  ];

  @override
  void initState() {
    super.initState();

    builder
      ..nodeSeparation = (100)
      ..levelSeparation = (40)
      ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM;

    appendDummyDataForMissingEarnings();

    loadTraversedTreeCache();
    loadReferralEarningsForDateRange();
    loadLastReadKPIFigures();

    setupLivePriceStreams();
  }

  @override
  void didUpdateWidget(MainPaymentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    appendDummyDataForMissingEarnings();

    setupLivePriceStreams();
  }

  Future<void> loadLastReadKPIFigures() async {
    Customer customer = Customer.fromSnapshot(await FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
        .doc(PrefUtil.getCurrentUserID())
        .get());
    if (!customer.documentExists()) return;

    _lastReadCurrentBalance = customer.last_read_current_balance ?? 0;
    _lastReadTotalChildren = customer.last_read_total_children ?? 0;

    if (mounted) {
      setState(() {});
    }
  }

  void setupLivePriceStreams() async {
    _liveCurrentBalanceStream?.cancel();
    _liveTotalChildrenStream?.cancel();

    _liveCurrentBalanceStream = FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_REFERRAL_CURRENT_BALANCE)
        .doc(PrefUtil.getCurrentUserID())
        .snapshots()
        .listen((snapshot) {
      _currentBalance = ReferralCurrentBalance.fromSnapshot(snapshot);
      if (mounted) {
        setState(() {});
      }
    });

    _liveTotalChildrenStream = FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
        .doc(PrefUtil.getCurrentUserID())
        .snapshots()
        .listen((snapshot) {
      _currentCustomerInfo = Customer.fromSnapshot(snapshot);
      if (mounted) {
        setState(() {});
      }
    });

    loadReferralEarningsForDateRange();
  }

  Future<void> loadReferralEarningsForDateRange() async {
    int daysToCollect = DATE_RANGES[selectedDateRange].numDays;
    DateTime now = DateTime.now();
    DateTime prevDate = now.subtract(Duration(days: daysToCollect));
    DateTime prevPrevDate = prevDate.subtract(Duration(days: daysToCollect));
    int nowTimeWindow = timeWindowForDate(now);
    int prevDateTimeWindow = timeWindowForDate(prevDate);
    int prevPrevDateTimeWindow = timeWindowForDate(prevPrevDate);

    _prevDateRangeTotalEarnings = 0;

    var prevSnapshots = await FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_REFERRAL_DAILY_EARNINGS)
        .where(ReferralDailyEarnings.FIELD_USER_ID,
            isEqualTo: PrefUtil.getCurrentUserID())
        .orderBy(ReferralDailyEarnings.FIELD_TIME_WINDOW, descending: false)
        .startAt([prevPrevDateTimeWindow]).endBefore(
            [prevDateTimeWindow]).get();
    prevSnapshots.docs.forEach((doc) {
      ReferralDailyEarnings earnings = ReferralDailyEarnings.fromSnapshot(doc);
      _prevDateRangeTotalEarnings += earnings.earning_amount!;
    });

    _liveDateRangeEarningsStream?.cancel();
    _liveDateRangeEarningsStream = FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_REFERRAL_DAILY_EARNINGS)
        .where(ReferralDailyEarnings.FIELD_USER_ID,
            isEqualTo: PrefUtil.getCurrentUserID())
        .orderBy(ReferralDailyEarnings.FIELD_TIME_WINDOW, descending: false)
        .startAfter([prevDateTimeWindow])
        .endAt([nowTimeWindow])
        .snapshots()
        .listen(
          (snapshots) {
            _dailyEarnings.clear();
            _dateRangeTotalEarnings = 0;

            int index = 0;
            snapshots.docs.forEach((snapshot) {
              ReferralDailyEarnings earning =
                  ReferralDailyEarnings.fromSnapshot(snapshot);
              earning.array_index = index++;
              _dailyEarnings.add(earning);
              _dateRangeTotalEarnings += earning.earning_amount!;
            });

            if (_dailyEarnings.length > 0) {
              isIncomeIncreasing =
                  (_dailyEarnings[_dailyEarnings.length - 1].earning_amount ??
                          0) >=
                      (_dailyEarnings[0].earning_amount ?? 0);
            } else {
              isIncomeIncreasing = true;
            }

            appendDummyDataForMissingEarnings();

            if (mounted) {
              setState(() {});
            }
          },
        );
  }

  void appendDummyDataForMissingEarnings() {
    // the graphing library can't handle below 3 numbers.
    while (_dailyEarnings.length < 3) {
      ReferralDailyEarnings dummy0Earnings;
      if (_dailyEarnings.length > 0) {
        dummy0Earnings = ReferralDailyEarnings.clone(_dailyEarnings[0]);
        dummy0Earnings.earning_amount = 0;
      } else {
        dummy0Earnings =
            new ReferralDailyEarnings.withArgs("", "", "", 0, 0, null, null);
      }
      dummy0Earnings.array_index = _dailyEarnings.length;
      _dailyEarnings.add(dummy0Earnings);
    }
  }

  Future<void> loadTraversedTreeCache() async {
    _traversedTree = ReferralTraversedTree.fromSnapshot(await FirebaseFirestore
        .instance
        .collection(FIRESTORE_PATHS.COL_REFERRAL_TRAVERSED_TREE)
        .doc(PrefUtil.getCurrentUserID())
        .get());

    if (_traversedTree!.documentExists()) {
      int len = (_traversedTree!.explored_nodes ?? []).length;
      for (int i = 0; i < len; i++) {
        SubTreeNode node = _traversedTree!.explored_nodes![i];
        NodePair nodePair = new NodePair(node, Node.Id(node.node_id));

        _traversedTree!.explored_nodes![i] = node;

        _mapNodes[node.node_id] = nodePair;
        if (_rootNodeInfo == null) {
          _rootNodeInfo = nodePair;
          _rootNodeId = node.node_id;
        }

        _initiallyCachedNodes.add(node.node_id);

        // don't await on this, when it finishes, will update UI then. Lazy-instantiation is WAY faster
        loadUpdatedNodeInfo(node, node.node_id, true);
      }
    } else {
      // create a new traversal node if one doesn't exist, and put root node as the first node of list
      _traversedTree = (new ReferralTraversedTree())
        ..explored_links = []
        ..explored_nodes = [];

      _rootNodeInfo =
          await loadUpdatedNodeInfo(null, PrefUtil.getCurrentUserID(), false);
      if (_rootNodeInfo == null) {
        return; // if we can't have a root node, don't bother
      }
      _traversedTree!.explored_nodes!.add(_rootNodeInfo!.treeNode);
    }

    graph.addNode(_rootNodeInfo!.graphNode);

    _traversedTree!.explored_links?.forEach((link) {
      NodePair startNode = _mapNodes[link.start_node]!;
      NodePair endNode = _mapNodes[link.end_node]!;

      graph.addEdge(startNode.graphNode, endNode.graphNode);

      if (!_nodeDirectChildren.containsKey(link.start_node)) {
        _nodeDirectChildren[link.start_node] = new Set();
      }

      _nodeDirectChildren[link.start_node]!.add(link.end_node);
    });

    graphLoadFinished = true;

    if (mounted) {
      setState(() {});
    }
  }

  Future<NodePair?> loadUpdatedNodeInfo(
      SubTreeNode? prevInfo, String nodeId, bool resetState) async {
    Customer customer = Customer.fromSnapshot(await FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
        .doc("" + nodeId)
        .get());
    //if (!customer.documentExists()) return null;

    NodePair? nodePair;

    if (_mapNodes.containsKey(nodeId)) {
      nodePair = _mapNodes[nodeId]!;
    } else {
      nodePair = new NodePair(new SubTreeNode(nodeId), Node.Id(nodeId));
    }

    SubTreeNode subNode = nodePair.treeNode;
    subNode.updated_num_direct_children = customer.num_direct_children ?? 0;
    subNode.updated_num_total_children = customer.num_total_children ?? 0;

    if (prevInfo != null) {
      subNode.last_cached_num_direct_children =
          prevInfo.last_cached_num_direct_children;
      subNode.last_cached_num_total_children =
          prevInfo.last_cached_num_total_children;
    }

    _mapNodes[nodeId] = nodePair;

    if (nodeId == _rootNodeId) {
      _rootNodeInfo = nodePair;
    }

    if (_initiallyCachedNodes.contains(nodeId)) {
      SubTreeNode treeNode = nodePair.treeNode;

      // if the # of direct-children at the node has changed, load its children
      if (treeNode.last_cached_num_direct_children !=
          treeNode.updated_num_direct_children) {
        _nodesUpdatedDirectChildren.add(treeNode.node_id);
      }
    }

    if (resetState && mounted) {
      setState(() {});
    }

    return nodePair;
  }

  Future<void> saveTraversedTreeInfo() async {
    // nothing to do if we don't have a tree
    if (_traversedTree == null ||
        (_traversedTree?.explored_nodes ?? []).length == 0) return;

    _traversedTree!.explored_nodes!.forEach((node) {
      node.last_cached_num_direct_children =
          node.updated_num_direct_children ?? 0;
      node.last_cached_num_total_children =
          node.updated_num_total_children ?? 0;

      node.updated_num_direct_children = null;
      node.updated_num_total_children = null;
    });

    await FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_REFERRAL_TRAVERSED_TREE)
        .doc(PrefUtil.getCurrentUserID())
        .set(_traversedTree!.toJson(), SetOptions(merge: true));
  }

  Future<void> saveLastReadFigures() async {
    Map<String, dynamic> updateFields = new Map();

    updateFields[Customer.FIELD_LAST_READ_CURRENT_BALANCE] =
        _currentBalance?.current_balance ?? 0;
    updateFields[Customer.FIELD_LAST_READ_TOTAL_CHILDREN] =
        _currentCustomerInfo?.num_total_children ?? 0;

    await FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
        .doc(PrefUtil.getCurrentUserID())
        .set(updateFields, SetOptions(merge: true));
  }

  @override
  void dispose() {
    _liveCurrentBalanceStream?.cancel();
    _liveTotalChildrenStream?.cancel();
    _liveDateRangeEarningsStream?.cancel();

    Future.delayed(Duration.zero, () async {
      await saveTraversedTreeInfo();
      await saveLastReadFigures();
    });

    super.dispose();
  }

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

  static int timeWindowForDate(DateTime date) {
    int day = date.day;
    int month = date.month;
    int year = date.year;

    return year * 10000 + month * 100 + day;
  }

  String _formatDouble(double? d, {int digits = 2}) {
    return AlphaNumericUtil.formatDouble(d ?? 0, digits);
  }

  static const FIELD_TYPE_CURRENT_BALANCE = 1;
  static const FIELD_TYPE_TOTAL_CHILDREN = 2;
  static const FIELD_TYPE_DATE_WINDOW = 3;

  Widget _textWidgetForPercentageChange(int fieldType) {
    bool dataMissing = false;
    double prevValue = 0, currentValue = 0;

    switch (fieldType) {
      case FIELD_TYPE_CURRENT_BALANCE:
        if (_currentBalance?.current_balance == null ||
            _lastReadCurrentBalance == null) {
          dataMissing = true;
        } else {
          prevValue = _lastReadCurrentBalance!;
          currentValue = _currentBalance!.current_balance!;
        }
        break;
      case FIELD_TYPE_TOTAL_CHILDREN:
        if (_currentCustomerInfo?.num_total_children == null ||
            _lastReadTotalChildren == null) {
          dataMissing = true;
        } else {
          prevValue = _lastReadTotalChildren! + 0.0;
          currentValue = _currentCustomerInfo!.num_total_children! + 0.0;
        }
        break;
      case FIELD_TYPE_DATE_WINDOW:
        prevValue = _prevDateRangeTotalEarnings;
        currentValue = _dateRangeTotalEarnings;
        break;
    }

    bool isPositive = true;
    String percentStr = "";
    if (!dataMissing) {
      if (prevValue != 0) {
        double delta = currentValue - prevValue;
        double deltaPercent = delta / prevValue;

        if (delta == 0) {
          dataMissing = true;
        } else {
          isPositive = deltaPercent >= 0;
          percentStr =
              '${deltaPercent > 0 ? '+' : ''}${AlphaNumericUtil.formatDouble(deltaPercent * 100.0, 1)}%';
        }
      }
    }

    return Text(
      dataMissing ? '' : percentStr,
      style: TextStyle(
          color: dataMissing || isPositive ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontFamily: 'Lato',
          fontSize: 12.0,
          letterSpacing: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    double vHeight = MediaQuery.of(context).size.height;
    double hWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Wrap(
          children: [
            // Earnings | Your Network Graph Selector
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
                      onTap: () {
                        graphMode = false;
                        setState(() {});
                      },
                      child: Container(
                        width: hWidth * 0.25,
                        height: vHeight * 0.045,
                        decoration: !graphMode
                            ? BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                borderRadius: BorderRadius.circular(40),
                              )
                            : BoxDecoration(),
                        child: Center(
                            child: Text(
                          'Earning',
                          style: !graphMode
                              ? selectedTextFieldStyle()
                              : unSelectedTextFieldStyle(),
                        )),
                      ),
                    ),
                    SizedBox(width: hWidth * 0.01),
                    GestureDetector(
                      onTap: () {
                        graphMode = true;
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 5, right: 5.0),
                        width: hWidth * 0.31,
                        height: vHeight * 0.045,
                        decoration: graphMode
                            ? BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                borderRadius: BorderRadius.circular(40),
                              )
                            : BoxDecoration(),
                        child: Center(
                            child: Text(
                          'Your Network',
                          style: graphMode
                              ? selectedTextFieldStyle()
                              : unSelectedTextFieldStyle(),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!graphMode) ...[
              Container(
                child: Column(
                  children: [
                    SizedBox(height: vHeight * 0.015),
                    Center(
                      child: Container(
                        height: vHeight * 0.001,
                        width: hWidth * 0.90,
                        color: Color(0xff3b3b3d),
                      ),
                    ),
                    SizedBox(height: vHeight * 0.015),
                    Container(
                      height: vHeight * 0.069,
                      padding: EdgeInsets.only(left: hWidth * 0.05),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: hWidth * 0.269,
                                  child: Row(
                                    children: [
                                      Text(
                                        _formatDouble(
                                            _currentBalance?.current_balance ??
                                                0),
                                        style: TextStyle(
                                            color: Color(0xfff0f0f0),
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Lato',
                                            fontSize: 15.0,
                                            letterSpacing: 2),
                                      ),
                                      Expanded(child: Container()),
                                      _textWidgetForPercentageChange(
                                          FIELD_TYPE_CURRENT_BALANCE),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: hWidth * 0.269,
                                  child: Row(
                                    children: [
                                      Text(
                                        '${_currentCustomerInfo?.num_total_children ?? 0}',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Lato',
                                            fontSize: 12.0,
                                            letterSpacing: 2),
                                      ),
                                      Expanded(child: Container()),
                                      _textWidgetForPercentageChange(
                                          FIELD_TYPE_TOTAL_CHILDREN),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Live Info',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
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
                            color: Color(0xff3b3b3d),
                            width: hWidth * 0.0015,
                          ),
                          SizedBox(width: 10.0),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: hWidth * 0.269,
                                  child: Row(
                                    children: [
                                      Text(
                                        _formatDouble(_dateRangeTotalEarnings),
                                        style: TextStyle(
                                            color: Color(0xfff0f0f0),
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Lato',
                                            fontSize: 15.0,
                                            letterSpacing: 2),
                                      ),
                                      Expanded(child: Container()),
                                      _textWidgetForPercentageChange(
                                          FIELD_TYPE_DATE_WINDOW),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Range Total',
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
                        color: Color(0xff3b3b3d),
                      ),
                    ),
                    SizedBox(height: vHeight * 0.015),
                  ],
                ),
              ),
              Container(
                color: Color(0xff1c1c1e),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Date Window Selector
                    Container(
                      height: vHeight * 0.06,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: DATE_RANGES.length,
                        itemBuilder: (context, index) {
                          bool isSelectedDateRange = selectedDateRange == index;

                          Decoration decoration;
                          if (isSelectedDateRange) {
                            decoration = BoxDecoration(
                              color: Color(0xff39383d),
                              borderRadius: BorderRadius.circular(8),
                            );
                          } else {
                            decoration = BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0));
                          }
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              selectedDateRange = index;
                              setState(() {});
                              loadReferralEarningsForDateRange();
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: hWidth * 0.04),
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              decoration: decoration,
                              child: Center(
                                child: Text(
                                  DATE_RANGES[index].windowStr,
                                  style: TextStyle(
                                    //color: Color(0xfffbfbfb),
                                    color: Colors.grey.shade100,
                                    fontSize: 18,
                                    fontFamily: 'Lato',
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: vHeight * 0.008),

                    // Earnings Graph
                    Container(
                      padding: EdgeInsets.only(
                          left: hWidth * 0.03, right: hWidth * 0.04),
                      child: SfCartesianChart(
                        enableAxisAnimation: true,
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: [
                          SplineAreaSeries<ReferralDailyEarnings, int>(
                            dataSource: _dailyEarnings,
                            splineType: SplineType.cardinal,
                            cardinalSplineTension: 0.5,
                            borderColor: Color.fromRGBO(
                                isIncomeIncreasing ? 0 : 255,
                                isIncomeIncreasing ? 255 : 0,
                                0,
                                1),
                            onCreateShader: (ShaderDetails details) {
                              return ui.Gradient.linear(details.rect.topCenter,
                                  details.rect.bottomCenter, <Color>[
                                Color.fromRGBO(isIncomeIncreasing ? 0 : 255,
                                    isIncomeIncreasing ? 255 : 0, 0, 0.7),
                                Color.fromRGBO(60, 60, 60, 0.4)
                              ], <double>[
                                0.1,
                                0.9
                              ]);
                            },
                            xValueMapper: (ReferralDailyEarnings earnings, _) =>
                                earnings.array_index,
                            yValueMapper: (ReferralDailyEarnings earnings, _) =>
                                earnings.earning_amount,
                            name: 'Earning',
                            borderWidth: selectedDateRange <= 1
                                ? 2
                                : selectedDateRange <= 3
                                    ? 1.5
                                    : 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        if (graphMode && graphLoadFinished) ...[
          Expanded(
            child: InteractiveViewer(
                constrained: false,
                boundaryMargin: EdgeInsets.all(1000),
                minScale: 0.00000000000001,
                maxScale: 5.6,
                child: GraphView(
                  graph: graph,
                  algorithm: SugiyamaAlgorithm(builder),
                  paint: Paint()
                    ..color = Colors.grey.shade400
                    ..strokeWidth = 2.5
                    ..style = PaintingStyle.stroke,
                  builder: (Node node) {
                    return nodeWidget(node.key!.value as String);
                  },
                )),
          ),
        ],
      ],
    );
  }

  Widget nodeWidget(String node_id) {
    double log10(num x) => log(x) / ln10;

    NodePair nodePair = _mapNodes[node_id]!;

    SubTreeNode treeNode = nodePair.treeNode;

    int numChildren = treeNode.updated_num_total_children ?? 0;

    int deltaChildren =
        numChildren - (treeNode.last_cached_num_total_children ?? 0);
    bool showDelta =
        (treeNode.last_cached_num_total_children != null) && deltaChildren > 0;
    int numDigits = numChildren <= 0 ? 1 : log10(numChildren).floor() + 1;

    bool invertColor = _nodesUpdatedDirectChildren.contains(node_id) ||
        !_initiallyCachedNodes.contains(node_id);

    double fontSize = 16.0, widthSize = 60.0;

    if (numDigits == 4) {
      fontSize = 15.0;
      widthSize = 70.0;
    } else if (numDigits >= 5) {
      fontSize = 14.0;
      widthSize = 80.0;
    }

    const whiteColor = Color(0xffffffff);
    const redColor = Color(0xffDE0000);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await loadNodeDirectChildren(node_id, true);
        setState(() {});
      },
      onDoubleTap: () async {
        removeSubTreeNode(node_id, false);
        setState(() {});
      },
      child: Stack(
        children: [
          Container(
            width: widthSize,
            height: 50,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: invertColor ? redColor : whiteColor,
            ),
            child: Center(
              child: Text(
                '${numChildren > 0 ? '${numChildren}' : '-'}',
                style: TextStyle(
                  color: invertColor ? whiteColor : redColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lato',
                  fontSize: fontSize,
                  //letterSpacing: 1.0,
                ),
              ),
            ),
          ),

          // notification icon
          if (showDelta) ...[
            Positioned(
              right: 0,
              top: 0,
              child: new Container(
                padding: EdgeInsets.all(2),
                decoration: new BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: BoxConstraints(
                  minWidth: 20,
                  minHeight: 14,
                ),
                child: Text(
                  '+ $deltaChildren',
                  style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void removeSubTreeNode(String nodeId, bool removeSelf) {
    // hack to remove ids from a map after iterating through them
    // https://stackoverflow.com/a/22410848
    var toRemoveId = [];
    _nodeDirectChildren[nodeId]?.forEach((childId) {
      removeSubTreeNode(childId, true);
      toRemoveId.add(childId);
    });

    _nodeDirectChildren[nodeId]?.removeWhere((e) => toRemoveId.contains(e));

    if (!removeSelf) return;

    NodePair node = _mapNodes[nodeId]!;
    graph.removeNode(node.graphNode);
    _removedNodes[nodeId] = node;
    _traversedTree!.explored_nodes!
        .removeWhere((elem) => elem.node_id == nodeId);
    _traversedTree!.explored_links!.removeWhere(
        (link) => (link.start_node == nodeId) || (link.end_node == nodeId));
  }

  Future<void> loadNodeDirectChildren(
      String parentId, bool clickInitiatedLoad) async {
    if (_traversedTree == null ||
        _rootNodeInfo ==
            null) // we can't continue without actually having loaded the initial tree
      return;

    var directChildrenSnapshot = await FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_FLAT_REFERRAL_TREE)
        .where(FlatAncestryNode.FIELD_PARENT_ID, isEqualTo: parentId)
        .where(FlatAncestryNode.FIELD_SEPARATION, isEqualTo: 0)
        .get();

    if (directChildrenSnapshot.docs.isEmpty) {
      return;
    }

    if (!_nodeDirectChildren.containsKey(parentId)) {
      _nodeDirectChildren[parentId] = new Set();
    }

    // user is clicking again a node that has already been fully expanded
    for (final snapshot in directChildrenSnapshot.docs) {
      FlatAncestryNode fNode = FlatAncestryNode.fromSnapshot(snapshot);

      // if we've already seen this child, don't do anything
      if (_nodeDirectChildren[parentId]!.contains(fNode.child_id!)) {
        continue;
      }
      _nodeDirectChildren[parentId]!.add(fNode.child_id!);

      NodePair? nodeInfo;
      if (_removedNodes.containsKey(fNode.child_id!)) {
        nodeInfo = _removedNodes[fNode.child_id!];
        _removedNodes.remove(fNode.child_id!);
      } else {
        nodeInfo = await loadUpdatedNodeInfo(null, fNode.child_id!, false);
      }
      if (nodeInfo != null) {
        _traversedTree!.explored_nodes!.add(nodeInfo.treeNode);
        _traversedTree!.explored_links!
            .add(SubTreeLink(parentId, fNode.child_id!));

        Node source = _mapNodes[parentId]!.graphNode;
        Node dest = nodeInfo.graphNode;

        graph.addEdge(source, dest);
      }
    }
  }
}

class DateWindow {
  DateWindow(this.windowStr, this.numDays);

  final String windowStr;
  final int numDays;
}
