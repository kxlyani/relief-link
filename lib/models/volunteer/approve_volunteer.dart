import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:relieflink/shared_preferences.dart';

class ApproveVolunteer extends StatefulWidget {
  const ApproveVolunteer({super.key});

  @override
  _ApproveVolunteerState createState() => _ApproveVolunteerState();
}

class _ApproveVolunteerState extends State<ApproveVolunteer> {
  Map<String, Map<String, dynamic>> volunteerData = {}; // Stores campaign details

  @override
  void initState() {
    super.initState();
    _fetchVolunteers();
  }

  Future<void> _fetchVolunteers() async {
    final url = Uri.parse(
        'https://relieflink-e824d-default-rtdb.firebaseio.com/volunteer.json');

    try {
      final response = await http.get(url);
      if (response.statusCode != 200 || response.body.isEmpty) {
        throw Exception("Failed to fetch volunteer data.");
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      Map<String, Map<String, dynamic>> filteredData = {};

      data.forEach((campaignId, value) {
        if (value['ngoEmail'] == universalId) {
          String campaignName = value['campaignName'] ?? "Unnamed Campaign";
          Map<String, dynamic> registeredVolunteers = value['registered'] ?? {};

          filteredData[campaignId] = {
            'campaignName': campaignName,
            'registered': registeredVolunteers,
          };
        }
      });

      setState(() {
        volunteerData = filteredData;
      });
    } catch (error) {
      print("Error fetching volunteers: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching volunteers: $error")),
      );
    }
  }

  Future<void> _approveVolunteer(String campaignId, String volunteerId) async {
    String sanitizedId = volunteerId.replaceAll('.', ',').replaceAll('@', '_at_');
    final url = Uri.parse(
        'https://relieflink-e824d-default-rtdb.firebaseio.com/volunteer/$campaignId/registered/$sanitizedId.json');

    try {
      final response = await http.patch(
        url,
        body: json.encode({'approved': true}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          volunteerData[campaignId]!['registered'][volunteerId]['approved'] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Approved volunteer: $volunteerId")),
        );
      } else {
        throw Exception("Failed to approve volunteer.");
      }
    } catch (error) {
      print("Error approving volunteer: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error approving volunteer: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Approve Volunteers"),
        backgroundColor: Colors.orange,
      ),
      body: volunteerData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: volunteerData.length,
              itemBuilder: (context, index) {
                String campaignId = volunteerData.keys.elementAt(index);
                String campaignName = volunteerData[campaignId]!['campaignName'];
                Map<String, dynamic> volunteers = volunteerData[campaignId]!['registered'];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaignName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...volunteers.entries.map((entry) {
                          String volunteerId = entry.key;
                          bool isApproved = entry.value['approved'] ?? false;
                          return ListTile(
                            title: Text(volunteerId.replaceAll('_at_', '@').replaceAll(',', '.')),
                            trailing: isApproved
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : ElevatedButton(
                                    onPressed: () => _approveVolunteer(campaignId, volunteerId),
                                    child: const Text("Approve"),
                                  ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}