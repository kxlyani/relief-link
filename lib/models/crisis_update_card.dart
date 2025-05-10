import 'package:flutter/material.dart';

class CrisisUpdateCard extends StatelessWidget {
  final String title;
  final String description;
  final String category;
  final String timestamp;
  final String criticalLevel;
  final VoidCallback onTap;

  const CrisisUpdateCard({
    super.key,
    required this.title,
    required this.description,
    required this.category,
    required this.timestamp,
    required this.criticalLevel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color levelColor;
    switch (criticalLevel.toLowerCase()) {
      case 'low':
        levelColor = Colors.green;
        break;
      case 'medium':
        levelColor = Colors.orange;
        break;
      case 'high':
        levelColor = Colors.redAccent;
        break;
      case 'critical':
        levelColor = Colors.red[900]!;
        break;
      default:
        levelColor = Colors.grey;
    }

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      criticalLevel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  
                ],
              ),
              Text(
                    timestamp,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.0,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
class Crisis {
  final String title;
  final String description;
  final String category;
  final String timestamp;
  final String criticalLevel;

  Crisis({
    required this.title,
    required this.description,
    required this.category,
    required this.timestamp,
    required this.criticalLevel,
  });

  factory Crisis.fromJson(Map<String, dynamic> json) {
    return Crisis(
      title: json['title'] ?? 'No Title',
      description: (json['body'] as String?)?.replaceAll(RegExp(r'<[^>]*>'), '') ??
          'No Description Available', // Remove HTML tags
      category: json['theme'] != null && json['theme'].isNotEmpty
          ? json['theme'][0]['name']
          : 'General',
      timestamp: json['date']['created'] ?? 'Unknown',
      criticalLevel: 'High', // Placeholder since ReliefWeb doesn't provide this
    );
  }
}