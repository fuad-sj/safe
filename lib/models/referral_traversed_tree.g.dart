// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_traversed_tree.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralTraversedTree _$ReferralTraversedTreeFromJson(
        Map<String, dynamic> json) =>
    ReferralTraversedTree()
      ..root_node = json['root_node'] == null
          ? null
          : SubTreeNode.fromJson(json['root_node'] as Map<String, dynamic>)
      ..explored_nodes = (json['explored_nodes'] as List<dynamic>?)
          ?.map((e) => SubTreeNode.fromJson(e as Map<String, dynamic>))
          .toList()
      ..explored_links = (json['explored_links'] as List<dynamic>?)
          ?.map((e) => SubTreeLink.fromJson(e as Map<String, dynamic>))
          .toList()
      ..date_last_updated =
          FirebaseDocument.DateTimeFromJson(json['date_last_updated']);

Map<String, dynamic> _$ReferralTraversedTreeToJson(
        ReferralTraversedTree instance) =>
    <String, dynamic>{
      'root_node': instance.root_node?.toJson(),
      'explored_nodes':
          instance.explored_nodes?.map((e) => e.toJson()).toList(),
      'explored_links':
          instance.explored_links?.map((e) => e.toJson()).toList(),
      'date_last_updated':
          FirebaseDocument.DateTimeToJson(instance.date_last_updated),
    };

SubTreeNode _$SubTreeNodeFromJson(Map<String, dynamic> json) => SubTreeNode(
      json['node_id'] as String,
      json['name'] as String,
      json['phone_number'] as String,
      json['last_seen_num_children'] as int,
      json['updated_num_children'] as int,
    );

Map<String, dynamic> _$SubTreeNodeToJson(SubTreeNode instance) =>
    <String, dynamic>{
      'node_id': instance.node_id,
      'name': instance.name,
      'phone_number': instance.phone_number,
      'last_seen_num_children': instance.last_seen_num_children,
      'updated_num_children': instance.updated_num_children,
    };

SubTreeLink _$SubTreeLinkFromJson(Map<String, dynamic> json) => SubTreeLink(
      json['start_node'] as String,
      json['end_node'] as String,
    );

Map<String, dynamic> _$SubTreeLinkToJson(SubTreeLink instance) =>
    <String, dynamic>{
      'start_node': instance.start_node,
      'end_node': instance.end_node,
    };
