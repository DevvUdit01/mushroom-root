class Offer {
  final String id;
  final String title;
  final String discountText;
  final String description;
  final String badgeText;

  Offer({
    required this.id,
    required this.title,
    required this.discountText,
    required this.description,
    required this.badgeText,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Special Offer',
      discountText: json['discountText'] ?? 'Discount',
      description: json['description'] ?? '',
      badgeText: json['badgeText'] ?? '',
    );
  }
}
