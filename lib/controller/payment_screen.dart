import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter_gen/gen_l10n/safe_localizations.dart';
import 'package:safe/controller/recent_transaction_screen.dart';
import 'package:safe/controller/send_money_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/models/referral_traversed_tree.dart';
import 'package:safe/utils/pref_util.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:safe/controller/graphview/GraphView.dart';
import 'dart:ui' as ui;

import 'main_payment_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class NodePair {
  SubTreeNode treeNode;
  Node graphNode;

  NodePair(this.treeNode, this.graphNode);
}

class _PaymentScreenState extends State<PaymentScreen> {
  final Graph graph = Graph();

  SugiyamaConfiguration builder = SugiyamaConfiguration()
    ..bendPointShape = CurvedBendPointShape(curveLength: 20);
  late int bottomIndex;

  ReferralTraversedTree? _traversedTree;

  NodePair? _rootNodeInfo = null; // useful for resetting the graph
  Map<String, NodePair> _mapNodes = Map();
  Map<String, Set<String>> _nodeDirectChildren = Map();
  Set<String> _nodesNeedingReloadingChildren = Set();
  bool graphLoadFinished = false;
  Map<String, NodePair> _removedNodes = Map();

  void changeScreenPayment(int? index) {
    setState(() {
      bottomIndex = index!;
    });
  }

  var paymentPages = [
    homePage(),
    sendMoneyScreen(),
    RecentTransactionsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    bottomIndex = 0;

    builder
      ..nodeSeparation = (15)
      ..levelSeparation = (15)
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
        NodePair? updatedNodeInfo =
            await loadUpdatedNodeInfo(node, node.node_id);
        if (updatedNodeInfo == null) {
          return;
        }
        _traversedTree!.explored_nodes![i] = updatedNodeInfo.treeNode;

        _mapNodes[node.node_id] = updatedNodeInfo;
        if (_rootNodeInfo == null) {
          _rootNodeInfo = updatedNodeInfo;
        }

        SubTreeNode treeNode = updatedNodeInfo.treeNode;
        // if the # of direct-children at the node has changed, load its children
        if (treeNode.last_cached_num_direct_children !=
            treeNode.updated_num_direct_children) {
          _nodesNeedingReloadingChildren.add(treeNode.node_id);
        }
      }
    } else {
      // create a new traversal node if one doesn't exist, and put root node as the first node of list
      _traversedTree = (new ReferralTraversedTree())
        ..explored_links = []
        ..explored_nodes = [];

      _rootNodeInfo =
          await loadUpdatedNodeInfo(null, PrefUtil.getCurrentUserID());
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

    for (final nodeId in _nodesNeedingReloadingChildren) {
      //await loadNodeDirectChildren(nodeId, false);
    }

    graphLoadFinished = true;

    if (mounted) {
      setState(() {});
    }
  }

  Future<NodePair?> loadUpdatedNodeInfo(
      SubTreeNode? prevInfo, String nodeId) async {
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
      _mapNodes[nodeId] = nodePair;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(bottomIndex == 0 ? 0xff1c1c1e : 0xffffffff),
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.05,
        backgroundColor: Color(bottomIndex == 0 ? 0xff1c1c1e : 0xffffffff),
        elevation: 0.0,
        leading: MaterialButton(
          elevation: 6.0,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xffDD0000),
          ),
          shape: CircleBorder(),
        ),
        centerTitle: true,
        title: Text(
          'Payments',
          style: TextStyle(
              color: Color(bottomIndex == 0 ? 0xffffffff : 0xff1c1c1e),
              fontWeight: FontWeight.w800,
              fontFamily: 'Lato',
              fontSize: 21.0,
              letterSpacing: 1),
        ),
        actions: <Widget>[],
      ),
      body: paymentPages[bottomIndex],
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.05,
        child: BubbleBottomBar(
          backgroundColor: Color(bottomIndex == 0 ? 0xff1c1c1e : 0xffffffff),
          opacity: 1.0,
          hasNotch: true,
          currentIndex: bottomIndex,
          onTap: changeScreenPayment,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          items: <BubbleBottomBarItem>[
            BubbleBottomBarItem(
              backgroundColor: Color(0xffDE0000),
              icon: Icon(
                Icons.home,
                color: Color(bottomIndex == 0 ? 0xffffffff : 0xff1c1c1e),
              ),
              activeIcon: Icon(
                Icons.home,
                color: Colors.white,
              ),
              title: Text(
                "Home",
                style: TextStyle(color: Colors.white),
              ),
            ),
            BubbleBottomBarItem(
              showBadge: true,
              badge: Text("5"),
              badgeColor: Colors.green,
              backgroundColor: Color(0xffDE0000),
              icon: Icon(Icons.monetization_on,
                  color: Color(bottomIndex == 0 ? 0xffffffff : 0xff1c1c1e)),
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
                Icons.history,
                color: Color(bottomIndex == 0 ? 0xffffffff : 0xff1c1c1e),
              ),
              activeIcon: Icon(
                Icons.history,
                color: Colors.white,
              ),
              title: Text(
                "Recent",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget nodeWidget(String node_id) {
    NodePair nodePair = _mapNodes[node_id]!;

    bool didTotalChildrenChange =
        nodePair.treeNode.updated_num_total_children !=
            nodePair.treeNode.last_cached_num_total_children;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await loadNodeDirectChildren(node_id, true);
        setState(() {});
      },
      child: Container(
          width: 100,
          height: 50,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                  color: didTotalChildrenChange
                      ? Colors.red[100]!
                      : Colors.blue[100]!,
                  spreadRadius: 1),
            ],
          ),
          child: Text('${nodePair.treeNode.updated_num_total_children}')),
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
    if (clickInitiatedLoad &&
        (directChildrenSnapshot.docs.length ==
            _nodeDirectChildren[parentId]!.length)) {
      removeSubTreeNode(parentId, false);
    } else {
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
          nodeInfo = await loadUpdatedNodeInfo(null, fNode.child_id!);
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
