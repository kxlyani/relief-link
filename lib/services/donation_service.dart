import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:relieflink/shared_preferences.dart';

// class DonationService {

Future<int> verifyIfAccExists(String email) async {
  int donations = 0;
  final Uri url = Uri.https(
    "relieflink-e824d-default-rtdb.firebaseio.com",
    "users.json",
  );

  final Uri url2 = Uri.https(
    "relieflink-e824d-default-rtdb.firebaseio.com",
    "ngos.json",
  );

  bool emailFound = false;

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic>? users = json.decode(response.body);
      if (users != null) {
        for (var entry in users.entries) {
          var user = entry.value;
          if (user['email'] != null &&
              user['email'].toString().trim().toLowerCase() ==
                  email.trim().toLowerCase()) {
            donations = user['total_donation'];
            print('Email found in users.json ✅');
            emailFound = true;
          }
        }
      }
    } else {
      print("Failed to fetch users data: ${response.statusCode}");
    }

    final response2 = await http.get(url2);
    if (response2.statusCode == 200) {
      final Map<String, dynamic>? users2 = json.decode(response2.body);
      if (users2 != null) {
        for (var entry in users2.entries) {
          var user = entry.value;
          if (user['email'] != null &&
              user['email'].toString().trim().toLowerCase() ==
                  email.trim().toLowerCase()) {
                     donations = user['total_donation'];
            print('Email found in ngos.json ✅');
            emailFound = true;
          }
        }
      }
    } else {
      print("Failed to fetch ngos data: ${response2.statusCode}");
    }

    if (!emailFound) {
      print('Email NOT found ❌');
    }

    return donations;
  } catch (error) {
    print("Error: $error");
    return 0;
  }
}

Future<int> getTotalDonations() async {
  return verifyIfAccExists(universalId);
  // Encode email for Firebase key

  //   final apiUrl = Uri.parse(
  //       'https://relieflink-e824d-default-rtdb.firebaseio.com/users/$universalId.json');

  //   try {
  //     final response = await http.get(apiUrl);

  //     if (response.statusCode == 200) {
  //       if (response.body.isEmpty || response.body == "null") {
  //         return 0; // User data does not exist
  //       }

  //       final data = jsonDecode(response.body);

  //       if (data is! Map<String, dynamic>) {
  //         print("Invalid data format received");
  //         return 0;
  //       }

  //       // Retrieve total_donation field
  //       int totalDonations = (data['total_donation'] ?? 0) as int;

  //       return totalDonations;
  //     } else {
  //       print("Error fetching user data: ${response.statusCode}");
  //       return 0;
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //     return 0;
  //   }
}
// }
