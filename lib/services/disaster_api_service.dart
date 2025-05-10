import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:relieflink/models/disaster_event.dart';

class DisasterApiService {
  final String apiUrl = 'https://eonet.gsfc.nasa.gov/api/v3/events';

  Future<List<DisasterEvent>> getRecentDisasters() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Adapt this based on the API response structure
        List<DisasterEvent> disasters = [];
        for (var event in data['events']) {
          disasters.add(DisasterEvent.fromJson({
            'type': event['categories'][0]['title'],
            'title': event['title'],
            'description': 'Location: ${event['geometry'][0]['coordinates'].join(', ')}',
            'date': event['geometry'][0]['date'],
          }));
        }
        
        return disasters;
      } else {
        throw Exception('Failed to load disaster data');
      }
    } catch (e) {
      print('Error fetching disaster data: $e');
      return [];
    }
  }
}