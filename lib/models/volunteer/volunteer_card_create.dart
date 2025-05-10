import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:relieflink/screens/profile_screen.dart';

class CreateVolunteerCard extends StatefulWidget {
  const CreateVolunteerCard({super.key, required this.ngoEmail});

  final String ngoEmail;

  @override
  _CreateVolunteerCardState createState() => _CreateVolunteerCardState();
}

class _CreateVolunteerCardState extends State<CreateVolunteerCard> {
  final _formKey = GlobalKey<FormState>();
  String? _imageURL;
  String? _campaignName;
  String? _description;
  String? _volunteers;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final campaign = {
        "ngoEmail": widget.ngoEmail,
        "imageURL": _imageURL,
        "campaignName": _campaignName,
        "description": _description,
        "volunteers": _volunteers,
      };

      final url = Uri.parse(
          'https://relieflink-e824d-default-rtdb.firebaseio.com/volunteer.json');
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
      appBar: AppBar(title: const Text('Create Volunteer Request')),
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
                    labelText: 'ImageURLCover',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a cover image' : null,
                  onSaved: (value) => _imageURL = value,
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
                    labelText: 'No. of volunteers Required',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty
                      ? 'Enter no. of volunteers required'
                      : null,
                  onSaved: (value) => _volunteers = value,
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Send Volunteer Request'),
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
