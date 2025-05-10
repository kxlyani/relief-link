import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:relieflink/models/volunteer/announcements_screen.dart';
import 'package:relieflink/shared_preferences.dart'; // Ensure this has `universalId`

class YourVolunteer extends StatefulWidget {
  const YourVolunteer({super.key});

  @override
  State<YourVolunteer> createState() => _YourVolunteerState();
}

class _YourVolunteerState extends State<YourVolunteer> {
  List<Map<String, String>> _approvedCampaigns = [];

  @override
  void initState() {
    super.initState();
    _fetchApprovedCampaigns();
  }

  Future<void> _fetchApprovedCampaigns() async {
    final url = Uri.parse(
      'https://relieflink-e824d-default-rtdb.firebaseio.com/volunteer.json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200 || response.body == "null" || response.body.isEmpty) {
        throw Exception("No campaigns found.");
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      String sanitizedId = universalId.replaceAll('.', ',').replaceAll('@', '_at_');

      List<Map<String, String>> approvedList = [];

      data.forEach((campaignId, campaignData) {
        if (campaignData['registered'] != null &&
            campaignData['registered'][sanitizedId] != null &&
            campaignData['registered'][sanitizedId]['approved'] == true) {
          approvedList.add({
            "campaignId": campaignId, // Store campaign ID for navigation
            "title": campaignData["title"] ?? "Volunteer Campaign",
            "ngoEmail": campaignData["ngoEmail"] ?? "Unknown NGO",
            "description": campaignData["description"] ?? "No description",
          });
        }
      });

      setState(() {
        _approvedCampaigns = approvedList;
      });
    } catch (error) {
      print("Error fetching approved campaigns: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Volunteer Campaigns")),
      body: _approvedCampaigns.isEmpty
          ? const Center(
              child: Text(
                "You aren't approved for any event",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _approvedCampaigns.length,
              itemBuilder: (ctx, index) {
                final campaign = _approvedCampaigns[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign["title"]!,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text("Organized by: ${campaign["ngoEmail"]}"),
                        const SizedBox(height: 8),
                        Text(campaign["description"]!),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              // Pass the correct campaign ID when navigating
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => AnnouncementsScreen(
                                    campaignId: campaign["campaignId"]!,
                                  ),
                                ),
                              );
                            },
                            child: const Text("View Announcements"),
                          ),
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
