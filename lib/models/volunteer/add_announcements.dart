import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:relieflink/shared_preferences.dart'; // To access universalId

class AddAnnouncements extends StatefulWidget {
  const AddAnnouncements({super.key});

  @override
  _AddAnnouncementsState createState() => _AddAnnouncementsState();
}

class _AddAnnouncementsState extends State<AddAnnouncements> {
  List<Map<String, String>> _campaigns = [];

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
  }

  Future<void> _fetchCampaigns() async {
    final url = Uri.parse(
      'https://relieflink-e824d-default-rtdb.firebaseio.com/volunteer.json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200 || response.body == "null" || response.body.isEmpty) {
        throw Exception("No campaigns found.");
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      List<Map<String, String>> campaignsList = [];

      data.forEach((id, campaign) {
        if (campaign["ngoEmail"] == universalId) {
          campaignsList.add({"id": id, "title": campaign["campaignName"] ?? "Untitled Campaign"});

        }
      });

      setState(() {
        _campaigns = campaignsList;
      });
    } catch (error) {
      print("Error fetching campaigns: $error");
    }
  }

  void _navigateToAnnouncementPage(String campaignId, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AnnounceFormScreen(campaignId: campaignId, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Volunteer Campaigns")),
      body: _campaigns.isEmpty
          ? const Center(
              child: Text(
                "No campaigns found.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _campaigns.length,
              itemBuilder: (ctx, index) {
                final campaign = _campaigns[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(campaign["title"] ?? ""),
                    trailing: ElevatedButton(
                      onPressed: () => _navigateToAnnouncementPage(campaign["id"]!, campaign["title"]!),
                      child: const Text("Announce"),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class AnnounceFormScreen extends StatefulWidget {
  final String campaignId;
  final String title;

  const AnnounceFormScreen({super.key, required this.campaignId, required this.title});

  @override
  _AnnounceFormScreenState createState() => _AnnounceFormScreenState();
}

class _AnnounceFormScreenState extends State<AnnounceFormScreen> {
  final TextEditingController _messageController = TextEditingController();

  Future<void> _submitAnnouncement() async {
    if (_messageController.text.trim().isEmpty) return;

    final url = Uri.parse(
      'https://relieflink-e824d-default-rtdb.firebaseio.com/volunteer/${widget.campaignId}/announcements.json',
    );

    final announcementData = json.encode({
      "message": _messageController.text.trim(),
      "timestamp": DateTime.now().toIso8601String(),
    });

    try {
      final response = await http.post(
        url,
        body: announcementData,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement posted successfully!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Failed to post announcement.");
      }
    } catch (error) {
      print("Error posting announcement: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Announce for ${widget.title}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Announcement Message",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitAnnouncement,
              child: const Text("Post Announcement"),
            ),
          ],
        ),
      ),
    );
  }
}
