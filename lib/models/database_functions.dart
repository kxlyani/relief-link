import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class DisasterDataFetcher {
  final String firebaseUrl = 'https://relieflink-e824d-default-rtdb.firebaseio.com/disasters.json'; // Replace with your Firebase URL

  /// Fetches data from all APIs and stores it in Firebase RTDB using REST API
  Future<void> fetchAndStoreDisasters() async {
    await _fetchFromReliefWeb();
    await _fetchFromUSGS();
    await _fetchFromGDACS();
  }

  /// Fetches disaster data from the ReliefWeb API
  Future<void> _fetchFromReliefWeb() async {
    const String apiUrl = 'https://api.reliefweb.int/v1/disasters';
    
    try {
      final response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null) {
          for (var disaster in data['data']) {
            String id = "RW_${disaster['id']}";
            String type = disaster['fields']['type'] ?? 'Unknown';
            String description = disaster['fields']['description'] ?? 'No description available';
            double lat = disaster['fields']['country']['location']['lat'] ?? 0.0;
            double lng = disaster['fields']['country']['location']['lon'] ?? 0.0;
            String severity = disaster['fields']['severity'] ?? 'Moderate';

            await _storeInFirebase(id, type, description, lat, lng, severity);
          }
        }
      } else {
        print('Failed to fetch data from ReliefWeb: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ReliefWeb data: $e');
    }
  }

  /// Fetches earthquake data from the USGS API
  Future<void> _fetchFromUSGS() async {
    const String apiUrl = 'https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&limit=20';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['features'] != null) {
          for (var earthquake in data['features']) {
            String id = "USGS_${earthquake['id']}";
            String type = earthquake['properties']['type'] ?? 'Earthquake';
            String description = earthquake['properties']['title'] ?? 'No details';
            double lat = earthquake['geometry']['coordinates'][1] ?? 0.0;
            double lng = earthquake['geometry']['coordinates'][0] ?? 0.0;
            double magnitude = earthquake['properties']['mag'] ?? 0.0;
            String severity = magnitude > 6.0 ? "Critical" : "Moderate";

            await _storeInFirebase(id, type, description, lat, lng, severity);
          }
        }
      } else {
        print('Failed to fetch data from USGS: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching USGS earthquake data: $e');
    }
  }

  /// Fetches disaster alerts from the GDACS API
  Future<void> _fetchFromGDACS() async {
  const String apiUrl = 'https://www.gdacs.org/xml/rss.xml'; // GDACS RSS feed URL

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final xmlString = response.body;
      print('GDACS data fetched. Parsing XML...');

      // Parse the XML data
      final document = xml.XmlDocument.parse(xmlString);
      final items = document.findAllElements('item'); // RSS items

      for (var item in items) {
        // ignore: unused_local_variable
        final title = item.findElements('title').first.text;
        // ignore: unused_local_variable
        final description = item.findElements('description').first.text;
        // ignore: unused_local_variable
        final link = item.findElements('link').first.text;
        // ignore: unused_local_variable
        final pubDate = item.findElements('pubDate').first.text;

      }
    } else {
      print('Failed to fetch data from GDACS: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching GDACS disaster data: $e');
  }
}
  /// Stores disaster data in Firebase Realtime Database via REST API
  Future<void> _storeInFirebase(String id, String type, String description, double lat, double lng, String severity) async {
    final String url = 'https://relieflink-e824d-default-rtdb.firebaseio.com/disasters/$id.json'; // Replace with your Firebase URL

    final Map<String, dynamic> disasterData = {
      'type': type,
      'description': description,
      'latitude': lat,
      'longitude': lng,
      'criticalLevel': severity,
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        body: json.encode(disasterData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Successfully stored disaster data: $id');
      } else {
        print('Failed to store data in Firebase: ${response.statusCode}');
      }
    } catch (e) {
      print('Error storing data in Firebase: $e');
    }
  }
}
