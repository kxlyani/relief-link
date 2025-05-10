class CampaignService {
  static Future<int> getCampaignsSupported() async {
    await Future.delayed(Duration(seconds: 2)); // Simulating API call
    return 30; // Example number of campaigns supported
  }
}
