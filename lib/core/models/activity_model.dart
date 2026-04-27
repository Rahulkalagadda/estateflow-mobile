class ActivityModel {
  final String id;
  final String type; // 'Call', 'Note', 'Visit'
  final String title;
  final String description;
  final String leadId;
  final DateTime createdAt;
  final String status;

  ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.leadId,
    required this.createdAt,
    required this.status,
  });
}
