import 'dart:convert';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:relieflink/login/loginscreen.dart';
import 'package:relieflink/login/ngosignup2.dart';
import 'package:http/http.dart' as http;
import 'package:relieflink/login/signupscreen.dart';
import 'package:relieflink/models/users.dart';

class NGOSignUpScreen extends StatefulWidget {
  const NGOSignUpScreen({super.key});

  @override
  State<NGOSignUpScreen> createState() => _NGOSignUpScreenState();
}

class _NGOSignUpScreenState extends State<NGOSignUpScreen> {
  final _form = GlobalKey<FormState>();
  String _enteredEmail = '';
  String enteredNGOName = '';
  String enteredContactPerson = '';
  String enteredRegistrationNumber = '';
  String enteredAddress = '';
  String enteredCity = '';
  String enteredState = '';
  String enteredCountry = '';
  String enteredContact = '';
  String enteredWebsite = '';
  String enteredMissionStatement = '';

  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();

    bool shouldSend = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Send OTP?"),
        content: Text("Do you want to send the OTP to $_enteredEmail?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No")),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes")),
        ],
      ),
    );
    if (shouldSend == true) {
      if (await verifyIfAccExists(_enteredEmail) == false) {
        sendOTP();
        final ngo = NGO(
          email: _enteredEmail,
          ngoName: enteredNGOName,
          contactPerson: enteredContactPerson,
          registrationNumber: enteredRegistrationNumber,
          address: enteredAddress,
          city: enteredCity,
          state: enteredState,
          country: enteredCountry,
          contact: enteredContact,
          website: enteredWebsite,
          missionStatement: enteredMissionStatement,
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => NGOSignUpScreen2(
                    email: _enteredEmail,
                    ngo: ngo,
                  )),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Email already registered. Please log in.")),
        );
      }
    }
  }

  void sendOTP() {
    EmailOTP.config(
      appName: 'ReliefLink',
      otpType: OTPType.numeric,
      expiry: 60000,
      emailTheme: EmailTheme.v6,
      appEmail: 'support@relieflink.org',
      otpLength: 4,
    );
    EmailOTP.sendOTP(email: _enteredEmail);
  }

  Future<bool> verifyIfAccExists(String email) async {
    final Uri url = Uri.https("relieflink-e824d-default-rtdb.firebaseio.com", "ngos.json");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic>? ngos = json.decode(response.body);
        if (ngos != null) {
          for (var entry in ngos.entries) {
            var ngo = entry.value;
            if (ngo['email'] != null &&
                ngo['email'].toString().trim().toLowerCase() ==
                    email.trim().toLowerCase()) {
              return true;
            }
          }
        }
      }
    } catch (error) {
      print("Error: \$error");
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF2D7DD2),
        body: Center(
          child: SingleChildScrollView(
            child: Card(
              color: Colors.white,
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _form,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Email Address'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value!.isEmpty || !value.contains('@') ? 'Invalid email' : null,
                        onSaved: (value) => _enteredEmail = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'NGO Name'),
                        onSaved: (value) => enteredNGOName = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Contact Person'),
                        onSaved: (value) => enteredContactPerson = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Registration Number'),
                        onSaved: (value) => enteredRegistrationNumber = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Address'),
                        onSaved: (value) => enteredAddress = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'City'),
                        onSaved: (value) => enteredCity = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'State'),
                        onSaved: (value) => enteredState = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Country'),
                        onSaved: (value) => enteredCountry = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Contact Number'),
                        keyboardType: TextInputType.phone,
                        onSaved: (value) => enteredContact = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Website'),
                        onSaved: (value) => enteredWebsite = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Mission Statement'),
                        maxLines: 3,
                        onSaved: (value) => enteredMissionStatement = value!,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Send OTP'),
                      ),
                      const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()),
                                );
                              },
                              child: const Text('I already have an Account', style: TextStyle(color: Colors.black),),
                            ),
                      TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SignUpScreen()),
                                );
                              },
                              child: const Text('Register as a citizen', style: TextStyle(color: Color.fromARGB(255, 76, 150, 189)),),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
