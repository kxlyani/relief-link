import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:relieflink/screens/volunteer_screen.dart';
import 'package:relieflink/shared_preferences.dart';

class VolunteerPage extends StatefulWidget {
  const VolunteerPage({
    super.key,
    required this.title,
    required this.organization, // NGO Email
    required this.description,
    required this.imageUrl,
  });

  final String title;
  final String organization; // NGO Email
  final String description;
  final String imageUrl;

  @override
  State<VolunteerPage> createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  bool? _isApproved; // null = not registered, false = pending, true = approved

  @override
  void initState() {
    super.initState();
    _checkApprovalStatus();
  }

  Future<void> _checkApprovalStatus() async {
    final url = Uri.parse(
      'https://relieflink-e824d-default-rtdb.firebaseio.com/volunteer.json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200 || response.body == "null" || response.body.isEmpty) {
        throw Exception("No volunteer campaigns found.");
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      String? campaignId;

      // Find the campaign for this NGO
      data.forEach((key, value) {
        if (value['ngoEmail'] == widget.organization) {
          campaignId = key;
        }
      });

      if (campaignId == null) return;

      // 🔹 Firebase-safe ID for current user
      String sanitizedId = universalId.replaceAll('.', ',').replaceAll('@', '_at_');

      final checkUrl = Uri.parse(
        'https://relieflink-e824d-default-rtdb.firebaseio.com/volunteer/$campaignId/registered/$sanitizedId.json',
      );

      final checkResponse = await http.get(checkUrl);
      if (checkResponse.statusCode == 200 && checkResponse.body != "null") {
        final registrationData = json.decode(checkResponse.body);
        setState(() {
          _isApproved = registrationData["approved"] ?? false;
        });
      }
    } catch (error) {
      print("Error checking approval status: $error");
    }
  }

  Future<void> _registerVolunteer(BuildContext context) async {
    final url = Uri.parse(
      'https://relieflink-e824d-default-rtdb.firebaseio.com/volunteer.json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200 || response.body == "null" || response.body.isEmpty) {
        throw Exception("No volunteer campaigns found.");
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      String? campaignId;

      data.forEach((key, value) {
        if (value['ngoEmail'] == widget.organization) {
          campaignId = key;
        }
      });

      if (campaignId == null) {
        throw Exception("Campaign not found for NGO: ${widget.organization}");
      }

      String sanitizedId = universalId.replaceAll('.', ',').replaceAll('@', '_at_');

      final updateUrl = Uri.parse(
        'https://relieflink-e824d-default-rtdb.firebaseio.com/volunteer/$campaignId/registered/$sanitizedId.json',
      );

      final requestBody = json.encode({
        "approved": false,
        "email": universalId,
      });

      final updateResponse = await http.patch(
        updateUrl,
        body: requestBody,
        headers: {'Content-Type': 'application/json'},
      );

      if (updateResponse.statusCode == 200 || updateResponse.statusCode == 201) {
        setState(() {
          _isApproved = false; // Mark as pending approval
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully registered as a volunteer!')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => VolunteerScreen()),
        );
      } else {
        throw Exception('Failed to update registration.');
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $error')),
      );
    }
  }

  void _showRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Registration"),
        content: const Text("Are you sure you want to register for this campaign?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _registerVolunteer(context);
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String buttonText = "Register Now";
    bool isButtonEnabled = true;

    if (_isApproved == true) {
      buttonText = "Approved";
      isButtonEnabled = false;
    } else if (_isApproved == false) {
      buttonText = "Approval Pending";
      isButtonEnabled = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title} Details"),
        backgroundColor: const Color.fromARGB(255, 216, 140, 69),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      widget.imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Organized by: ${widget.organization}',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20.0),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 216, 140, 69),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: isButtonEnabled ? () => _showRegistrationDialog(context) : null,
                      child: Text(buttonText, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
