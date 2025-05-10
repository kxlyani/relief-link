import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:relieflink/shared_preferences.dart'; // Ensure this handles universalId correctly.

class CampaignDonationPage extends StatefulWidget {
  final String campaignId;
  final String merchantId;

  const CampaignDonationPage({
    super.key,
    required this.campaignId,
    required this.merchantId,
  });

  @override
  _CampaignDonationPageState createState() => _CampaignDonationPageState();
}

class _CampaignDonationPageState extends State<CampaignDonationPage> {
  final _razorpay = Razorpay();
  late String campaignId;
  late String razorpayAccountId;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    campaignId = widget.campaignId;
    razorpayAccountId = widget.merchantId;

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // Fetch user ID from Firebase using email
  Future<String?> getUserIdByEmail(String email) async {
    final Uri url = Uri.https(
      "relieflink-e824d-default-rtdb.firebaseio.com",
      "users.json",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic>? users = json.decode(response.body);
        if (users != null) {
          for (var entry in users.entries) {
            var user = entry.value;
            if (user['email'].toString().trim().toLowerCase() ==
                email.trim().toLowerCase()) {
              return entry.key; // Return user ID
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching user ID: $e");
    }
    return null;
  }

  // Add or update donation amount in Firebase
  void _addDonation() async {
    int donatedAmount = int.tryParse(_amountController.text) ?? 0;
    if (donatedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter a valid donation amount")),
      );
      return;
    }

    // Fetch user ID from email
    String? userId = await getUserIdByEmail(universalId);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not found in database.")),
      );
      return;
    }

    final updateUrl = Uri.https(
      'relieflink-e824d-default-rtdb.firebaseio.com',
      'users/$userId.json',
    );

    try {
      // Fetch current donation amount
      final fetchResponse = await http.get(updateUrl);
      int previousTotal = 0;
      if (fetchResponse.statusCode == 200 && fetchResponse.body.isNotEmpty) {
        final data = json.decode(fetchResponse.body);
        previousTotal = data["total_donation"] ?? 0;
      }

      int newTotal = previousTotal + donatedAmount; // Update donation amount

      final updateResponse = await http.patch(
        updateUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"total_donation": newTotal}),
      );

      if (updateResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Payment Successful, Total Donated: ₹$newTotal")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update donation record.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Initiate Razorpay payment
  void _makeDonation() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Enter an amount and ensure details are loaded")),
      );
      return;
    }

    int? amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    amount *= 100; // Convert ₹ to paise

    var options = {
      "key": "rzp_test_6xSEgZDHbzAWKN", // Replace with your Razorpay API key
      "amount": amount,
      "currency": "INR",
      "name": "Donation to $campaignId",
      "description": "",
      "prefill": {"contact": "9876543210", "email": "donor@example.com"},
      "theme": {"color": "#3399cc"},
      "account": razorpayAccountId,
    };

    _razorpay.open(options);
  }

  // Razorpay Handlers
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _addDonation();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful: ${response.paymentId}")),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _addDonation();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("External Wallet Selected: ${response.walletName}")),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Donate to Campaign")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              campaignId,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Amount in ₹",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _makeDonation,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text("Donate Now"),
            ),
          ],
        ),
      ),
    );
  }
}
