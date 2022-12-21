// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_traversed_tree.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralTraversedTree _$ReferralTraversedTreeFromJson(
        Map<String, dynamic> json) =>
    ReferralTraversedTree()
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
      'explored_nodes':
          instance.explored_nodes?.map((e) => e.toJson()).toList(),
      'explored_links':
          instance.explored_links?.map((e) => e.toJson()).toList(),
      'date_last_updated':
          FirebaseDocument.DateTimeToJson(instance.date_last_updated),
    };

SubTreeNode _$SubTreeNodeFromJson(Map<String, dynamic> json) => SubTreeNode(
      json['node_id'] as String,
    )
      ..last_cached_num_direct_children =
          json['last_cached_num_direct_children'] as int?
      ..last_cached_num_total_children =
          json['last_cached_num_total_children'] as int?
      ..updated_num_direct_children =
          json['updated_num_direct_children'] as int?
      ..updated_num_total_children = json['updated_num_total_children'] as int?;

Map<String, dynamic> _$SubTreeNodeToJson(SubTreeNode instance) =>
    <String, dynamic>{
      'node_id': instance.node_id,
      'last_cached_num_direct_children':
          instance.last_cached_num_direct_children,
      'last_cached_num_total_children': instance.last_cached_num_total_children,
      'updated_num_direct_children': instance.updated_num_direct_children,
      'updated_num_total_children': instance.updated_num_total_children,
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
