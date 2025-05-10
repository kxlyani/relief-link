class NGOService {
  static Future<int> getNGOsHelped() async {
    await Future.delayed(Duration(seconds: 2)); // Simulating API call
    return 120; // Example number of NGOs helped
  }
}