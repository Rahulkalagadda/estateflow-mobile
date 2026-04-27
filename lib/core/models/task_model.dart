class TaskModel {
  final String id;
  final String tenantId;
  final String leadId;
  final String userId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.tenantId,
    required this.leadId,
    required this.userId,
    required this.title,
    this.description,
    required this.dueDate,
    required this.isCompleted,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      tenantId: json['tenantId'] ?? '',
      leadId: json['leadId'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : DateTime.now(),
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'leadId': leadId,
      'userId': userId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? tenantId,
    String? leadId,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      leadId: leadId ?? this.leadId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
