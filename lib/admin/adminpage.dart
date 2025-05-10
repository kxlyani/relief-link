import 'package:flutter/material.dart';
import 'package:relieflink/login/loginscreen.dart';
import 'package:relieflink/shared_preferences.dart';

String adminType = '';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key, required this.adminType});

  final String adminType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 300,),
          SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                              bool shouldExit = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Log Out?"),
                                  content: const Text(
                                      "You will be signed out of the application. Do you really want to log out?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text("Yes"),
                                    ),
                                  ],
                                ),
                              );
          
                              if (shouldExit == true) {
                                await saveAdminStatus(false);
                                adminLog = false;
                                print('The logstatus is $logStatus');
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginScreen()),
                                  (route) => false,
                                );
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Logout'),
                    ),
                  ),
        ],
      ),
    );
  }
}
