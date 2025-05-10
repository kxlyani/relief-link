import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:relieflink/screens/profile_screen.dart';

class CreateCampaignCard extends StatefulWidget {
  const CreateCampaignCard({super.key, required this.ngoEmail});

  final String ngoEmail;

  @override
  _CreateCampaignCardState createState() => _CreateCampaignCardState();
}

class _CreateCampaignCardState extends State<CreateCampaignCard> {
  final _formKey = GlobalKey<FormState>();
  String? _merchantId;
  String? _campaignName;
  String? _description;
  String? _goal;
  final String _raised = '0';

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final campaign = {
        "ngoEmail": widget.ngoEmail,
        "merchantId": _merchantId,
        "campaignName": _campaignName,
        "description": _description,
        "goal": _goal,
        "raised": _raised,
      };

      final url = Uri.parse(
          'https://relieflink-e824d-default-rtdb.firebaseio.com/campaigns.json');
      try {
        final response = await http.post(
          url,
          body: json.encode(campaign),
          headers: {'Content-Type': 'application/json'},
        );

        print('Response Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Campaign Created Successfully!')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (ctx) => ProfileScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.body}')),
          );
        }
      } catch (error) {
        print('Error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error occurred! Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Campaign')),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Campaign Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter Campaign Name' : null,
                  onSaved: (value) => _campaignName = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Merchant ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter Merchant ID' : null,
                  onSaved: (value) => _merchantId = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter Description' : null,
                  onSaved: (value) => _description = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Goal',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty
                      ? 'Enter how much funds you want to raise'
                      : null,
                  onSaved: (value) => _goal = value,
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Create Campaign'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
