import 'package:flutter/material.dart';

class PipelineStageModel {
  final String id;
  final String tenantId;
  final String name;
  final String color;
  final int order;

  PipelineStageModel({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.color,
    required this.order,
  });

  factory PipelineStageModel.fromJson(Map<String, dynamic> json) {
    return PipelineStageModel(
      id: json['id'] ?? '',
      tenantId: json['tenantId'] ?? '',
      name: json['name'] ?? '',
      color: json['color'] ?? '#CBD5E1',
      order: json['order'] ?? 0,
    );
  }

  Color get uiColor {
    final hexColor = color.replaceAll('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('FF$hexColor', radix: 16));
    }
    return Colors.grey;
  }
}
