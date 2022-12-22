import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:safe/controller/graphview/GraphView.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/models/referral_traversed_tree.dart';
import 'package:safe/utils/pref_util.dart';
import 'package:safe/controller/graphview/GraphView.dart';

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  _homePageState createState() => _homePageState();
}

class NodePair {
  SubTreeNode treeNode;
  Node graphNode;

  NodePair(this.treeNode, this.graphNode);
}

class _homePageState extends State<homePage> {
  final Graph graph = Graph();

  SugiyamaConfiguration builder = SugiyamaConfiguration()
    ..bendPointShape = CurvedBendPointShape(curveLength: 50);

  ReferralTraversedTree? _traversedTree;

  String? _rootNodeId;
  NodePair? _rootNodeInfo; // useful for resetting the graph

  Map<String, NodePair> _mapNodes = Map();
  Map<String, Set<String>> _nodeDirectChildren = Map();
  bool graphLoadFinished = false;
  Set<String> _nodesUpdatedDirectChildren = Set();
  Set<String> _initiallyCachedNodes = Set();
  Map<String, NodePair> _removedNodes = Map();

  @override
  void initState() {
    super.initState();

    builder
      ..nodeSeparation = (100)
      ..levelSeparation = (40)
      ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM;

    loadTraversedTreeCache();
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
    if (!customer.documentExists()) return null;

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

  @override
  void dispose() {
    Future.delayed(Duration.zero, () async {
      await saveTraversedTreeInfo();
    });
    super.dispose();
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
                        padding: EdgeInsets.only(
                            left: hWidth * 0.03, right: hWidth * 0.04),
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
                        padding: EdgeInsets.only(
                            left: hWidth * 0.03, right: hWidth * 0.04),
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
        if (graphLoadFinished) ...[
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
