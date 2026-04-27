class LeadEntity {
  final String id;
  final String initials;
  final String name;
  final String phone;
  final String email;
  final String status;
  final String property;
  final String propertyPrice;
  final String propertyImage;
  final String propertyIcon;
  final int leadScore;
  final String source;
  final String budgetRange;
  final String timeline;

  const LeadEntity({
    required this.id,
    required this.initials,
    required this.name,
    required this.phone,
    this.email = '',
    required this.status,
    required this.property,
    this.propertyPrice = '',
    this.propertyImage = '',
    this.propertyIcon = 'domain',
    this.leadScore = 0,
    this.source = '',
    this.budgetRange = '',
    this.timeline = '',
  });
}
