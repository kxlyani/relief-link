import 'package:flutter/material.dart';
import 'package:relieflink/models/impact_stat_card.dart';
import 'package:relieflink/services/donation_service.dart';
import 'package:relieflink/services/ngo_service.dart';
import 'package:relieflink/services/campaign_service.dart';

class TransparencyScreen extends StatelessWidget {
  const TransparencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impact & Transparency'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Impact',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Track how your donations are making a difference',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16.0),
              FutureBuilder<Map<String, String>>(
                future: fetchImpactStats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('No data available'));
                  }
                  final data = snapshot.data!;
                  return GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 1.2,
                    ),
                    children: [
                      ImpactStatCard(
                        icon: Icons.volunteer_activism,
                        label: 'Your Donations',
                        value: data['donations'] ?? '0',
                        color: Colors.blue,
                      ),
                      ImpactStatCard(
                        icon: Icons.people,
                        label: 'People Helped',
                        value: data['ngos_helped'] ?? '0',
                        color: Colors.green,
                      ),
                      ImpactStatCard(
                        icon: Icons.favorite,
                        label: 'Campaigns Supported',
                        value: data['campaigns_supported'] ?? '0',
                        color: Colors.red,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Fund Allocation',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                height: 200.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade700.withOpacity(0.9),
                      Colors.blue.shade900.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Fund Allocation Chart',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Recent Updates',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue.shade300,
                                child: const Icon(Icons.update, color: Colors.white),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Project Update ${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    Text(
                                      'Organization ${index + 1}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${index + 1}d ago',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          const Text(
                            'Update details about how funds are being used and the impact they\'re making in the affected area.',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton(
                                onPressed: () {},
                                child: const Text('View Full Report'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<Map<String, String>> fetchImpactStats() async {
  final donations = await getTotalDonations();
  final ngosHelped = await NGOService.getNGOsHelped();
  final campaignsSupported = await CampaignService.getCampaignsSupported();

  return {
    'donations': '₹$donations',
    'ngos_helped': ngosHelped.toString(),
    'campaigns_supported': campaignsSupported.toString(),
  };
}
