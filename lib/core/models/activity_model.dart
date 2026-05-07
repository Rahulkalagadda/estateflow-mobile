class ActivityModel {
  final String id;
  final String type;
  final String? leadId;
  final String? userId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final String? leadName;
  final String? userName;

  ActivityModel({
    required this.id,
    required this.type,
    this.leadId,
    this.userId,
    this.metadata,
    required this.createdAt,
    this.leadName,
    this.userName,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    String? leadName;
    if (json['lead'] != null) {
      leadName = "${json['lead']['firstName']} ${json['lead']['lastName']}";
    }
    
    String? userName;
    if (json['user'] != null) {
      userName = "${json['user']['firstName']} ${json['user']['lastName']}";
    }

    return ActivityModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      leadId: json['leadId'],
      userId: json['userId'],
      metadata: json['metadata'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      leadName: leadName,
      userName: userName,
    );
  }

  String get displayTitle {
    switch (type) {
      case 'NOTE_ADDED':
        return 'Note Added';
      case 'STAGE_CHANGED':
        return 'Stage Updated';
      case 'TASK_COMPLETED':
        return 'Task Completed';
      case 'LEAD_CREATED':
        return 'New Lead Created';
      default:
        return type.replaceAll('_', ' ');
    }
  }

  String get displayDescription {
    if (leadName != null) {
      return "For lead: $leadName";
    }
    return metadata?['description'] ?? '';
  }
}
