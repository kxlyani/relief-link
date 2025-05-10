class DisasterEvent {
  final String type;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime date;

  DisasterEvent({
    required this.type,
    required this.title, 
    required this.description,
    this.imageUrl,
    required this.date,
  });

  factory DisasterEvent.fromJson(Map<String, dynamic> json) {
    // This will vary based on the API you choose
    return DisasterEvent(
      type: json['type'] ?? 'DISASTER',
      title: json['title'] ?? 'Unknown Disaster',
      description: json['description'] ?? 'No details available',
      imageUrl: json['imageUrl'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}