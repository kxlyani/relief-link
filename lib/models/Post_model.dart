class Post {
  String id;
  String title;
  String description;
  String userId;
  int likes;
  String timestamp; // RTDB stores timestamps as strings (ISO format)

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.likes,
    required this.timestamp,
  });

  factory Post.fromJson(String id, Map<String, dynamic> data) {
    return Post(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? 'Unknown User',
      likes: data['likes'] ?? 0,
      timestamp: data['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'userId': userId,
      'likes': likes,
      'timestamp': timestamp,
    };
  }
}
