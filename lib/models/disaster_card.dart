import 'package:flutter/material.dart';
import 'package:relieflink/models/disaster_event.dart';

class DisasterCard extends StatelessWidget {
  final DisasterEvent disaster;
  
  const DisasterCard({super.key, required this.disaster});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with fallback
          Container(
            height: 180.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
              image: disaster.imageUrl != null ? DecorationImage(
                image: NetworkImage(disaster.imageUrl!),
                fit: BoxFit.cover,
              ) : null,
            ),
            child: disaster.imageUrl == null ? const Center(
              child: Icon(Icons.warning_amber_rounded, size: 48.0, color: Colors.grey),
            ) : null,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    disaster.type.toUpperCase(),
                    style: TextStyle(
                      color: Colors.red[800],
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  disaster.title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  disaster.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Details'),
                      onPressed: () {
                        // Show more details
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        // Share content
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark_border),
                      onPressed: () {
                        // Save content
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}