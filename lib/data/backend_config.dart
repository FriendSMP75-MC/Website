// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

const backendUrl = 'https://key-backend-for-friendsmp75-website.onrender.com/';
const accessToken = String.fromEnvironment("ACCESS_TOKEN");

class BackendData {
  // Get data from backend
  static Future<dynamic> retrieveData(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse(backendUrl + endpoint),
        headers: {'X-Access-Token': accessToken},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data;
      }
    } catch (e) {
      print('Error Retrieving Data from backend $e');
    }

    return 'Error Retrieving Data';
  }

  // Send data to backend

  static Future<String?> sendData(
    String endpoint,
    Map<String, dynamic> content,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(backendUrl + endpoint),
        headers: {
          'Content-Type': 'application/json',
          'X-Access-Token': accessToken,
        },
        body: jsonEncode(content),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        print("Backend error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error contacting backend! $e");
      return null;
    }
  }

  //Get

  // Get owner ID

  static Future<String?> getOwnerAuthID() async {
    try {
      final data = await retrieveData('check-owner');
      if (data != null) {
        return data['UUID_ID'] as String?;
      }
    } catch (e) {
      print('Error getting owner auth id: $e');
    }

    return null;
  }

  static Future<List<dynamic>?> getUUID() async {
    try {
      final result = await retrieveData('get-staff-uuids');
      if (result is List<dynamic>) {
        return result;
      }
      return null;
    } catch (e) {
      print('Error when getting uuid $e');
      return null;
    }
  }

  // Send

  //send UID
  static Future<String?> sendUUID(String uuid, String nickname) async {
    try {
      final result = await sendData('add-uuid', {
        'uuid': uuid,
        'nickname': nickname,
      });
      return result;
    } catch (e) {
      return 'Error: $e';
    }
  }
}
