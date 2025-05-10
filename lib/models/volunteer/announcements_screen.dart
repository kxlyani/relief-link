import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnnouncementsScreen extends StatefulWidget {
  final String campaignId; // Dynamic campaign ID
  const AnnouncementsScreen({super.key, required this.campaignId});

  @override
  _AnnouncementsScreenState createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<Map<String, dynamic>> _announcements = [];

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    final campaignId = widget.campaignId; // Get campaign ID from widget
    final url = Uri.parse(
      'https://relieflink-e824d-default-rtdb.firebaseio.com/volunteer/$campaignId/announcements.json',
    );

    print("🔍 Fetching from: $url"); // Debugging URL

    try {
      final response = await http.get(url);
      print("📡 Firebase Response: ${response.body}");

      if (response.statusCode != 200 || response.body == "null" || response.body.isEmpty) {
        throw Exception("No announcements found.");
      }

      final data = json.decode(response.body) as Map<String, dynamic>?;

      if (data == null || data.isEmpty) {
        throw Exception("No announcements available.");
      }

      List<Map<String, dynamic>> announcementsList = [];

      data.forEach((id, announcement) {
        announcementsList.add({
          "message": announcement["message"] ?? "No message",
          "timestamp": announcement["timestamp"] ?? "",
        });
      });

      // Sort announcements by timestamp (latest first)
      announcementsList.sort((a, b) => (b["timestamp"] ?? "").compareTo(a["timestamp"] ?? ""));

      setState(() {
        _announcements = announcementsList;
      });

      print("✅ Parsed Announcements: $_announcements");

    } catch (error) {
      print("❌ Error fetching announcements: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Announcements")),
      body: _announcements.isEmpty
          ? const Center(
              child: Text(
                "No announcements yet.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _announcements.length,
              itemBuilder: (ctx, index) {
                final announcement = _announcements[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement["message"],
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Posted at: ${announcement["timestamp"]}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
