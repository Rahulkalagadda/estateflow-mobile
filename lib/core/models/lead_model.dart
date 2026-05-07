class LeadModel {
  final String id;
  final String tenantId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String stageId;
  final String? assigneeId;
  final String? notes;
  final double? budget;
  final String? interestedProperty;
  final String? preapprovalStatus;
  final DateTime? expectedCloseDate;
  final String? location;
  final String? source;
  final DateTime createdAt;

  LeadModel({
    required this.id,
    required this.tenantId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    required this.stageId,
    this.assigneeId,
    this.notes,
    this.budget,
    this.interestedProperty,
    this.preapprovalStatus,
    this.expectedCloseDate,
    this.location,
    this.source,
    required this.createdAt,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] ?? '',
      tenantId: json['tenantId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'],
      phone: json['phone'],
      stageId: json['stageId'] ?? '',
      assigneeId: json['assigneeId'],
      notes: json['notes'],
      budget: json['budget'] != null ? (json['budget'] as num).toDouble() : null,
      interestedProperty: json['interestedProperty'],
      preapprovalStatus: json['preapprovalStatus'],
      expectedCloseDate: json['expectedCloseDate'] != null 
          ? DateTime.parse(json['expectedCloseDate']) 
          : null,
      location: json['location'],
      source: json['source'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'stageId': stageId,
      'assigneeId': assigneeId,
      'notes': notes,
      'budget': budget,
      'interestedProperty': interestedProperty,
      'preapprovalStatus': preapprovalStatus,
      'expectedCloseDate': expectedCloseDate?.toIso8601String(),
      'location': location,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  LeadModel copyWith({
    String? id,
    String? tenantId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? stageId,
    String? assigneeId,
    String? notes,
    double? budget,
    String? interestedProperty,
    String? preapprovalStatus,
    DateTime? expectedCloseDate,
    String? location,
    String? source,
    DateTime? createdAt,
  }) {
    return LeadModel(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      stageId: stageId ?? this.stageId,
      assigneeId: assigneeId ?? this.assigneeId,
      notes: notes ?? this.notes,
      budget: budget ?? this.budget,
      interestedProperty: interestedProperty ?? this.interestedProperty,
      preapprovalStatus: preapprovalStatus ?? this.preapprovalStatus,
      expectedCloseDate: expectedCloseDate ?? this.expectedCloseDate,
      location: location ?? this.location,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
