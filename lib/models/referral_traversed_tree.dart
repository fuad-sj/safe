import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe/models/firebase_document.dart';
import 'package:json_annotation/json_annotation.dart';

part 'referral_traversed_tree.g.dart';

@JsonSerializable(explicitToJson: true)
class ReferralTraversedTree extends FirebaseDocument {
  List<SubTreeNode>? explored_nodes;

  List<SubTreeLink>? explored_links;

  @JsonKey(
      fromJson: FirebaseDocument.DateTimeFromJson,
      toJson: FirebaseDocument.DateTimeToJson)
  DateTime? date_last_updated;

  ReferralTraversedTree();

  factory ReferralTraversedTree.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    ReferralTraversedTree treeNode = ReferralTraversedTree();

    var json = snapshot.data();
    if (json != null) {
      treeNode = _$ReferralTraversedTreeFromJson(json);
      treeNode.documentID = snapshot.id;
    }

    return treeNode;
  }

  Map<String, dynamic> toJson() => _$ReferralTraversedTreeToJson(this);
}

@JsonSerializable()
class SubTreeNode {
  String node_id;
  String name;
  String phone_number;

  int last_seen_num_children;
  int updated_num_children;

  SubTreeNode(String node_id, String name, String phone_number,
      int last_seen_num_children, int updated_num_children)
      : node_id = node_id,
        name = name,
        phone_number = phone_number,
        last_seen_num_children = last_seen_num_children,
        updated_num_children = updated_num_children;

  static SubTreeNode fromJson(Map<String, dynamic> json) =>
      _$SubTreeNodeFromJson(json);

  Map<String, dynamic> toJson() => _$SubTreeNodeToJson(this);
}

@JsonSerializable()
class SubTreeLink {
  String start_node;
  String end_node;

  SubTreeLink(String start_node, String end_node)
      : start_node = start_node,
        end_node = end_node;

  static SubTreeLink fromJson(Map<String, dynamic> json) =>
      _$SubTreeLinkFromJson(json);

  Map<String, dynamic> toJson() => _$SubTreeLinkToJson(this);
}
