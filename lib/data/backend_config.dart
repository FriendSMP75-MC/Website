// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:server_site/data/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const backendUrl = 'https://key-backend-for-friendsmp75-website.onrender.com/';
const accessToken = String.fromEnvironment("ACCESS_TOKEN");

SupabaseClient get supabase => Supabase.instance.client;
final user = SupabaseConfig.client.auth.currentUser;

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

  // Request data to remove data from backend
  static Future<String?> removeData(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse(backendUrl + endpoint),
        headers: {
          'Content-Type': 'application/json',
          'X-Access-Token': accessToken,
        },
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return ("Backend error: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      return ("Error contacting backend! $e");
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

  // Get UUID
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

  //send UUID
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

  static Future<String?> newAnnouncement(String title, String body) async {
    try {
      final author = SupabaseConfig.getDisplayName(user);
      final authorUUID = SupabaseConfig.getSupabaseUUID(user);
      final result = await sendData('new-announcements', {
        'title': title,
        'body': body,
        'author': author,
        'author_uuid': authorUUID,
      });

      return result;
    } catch (e) {
      return 'Error: $e';
    }
  }

  // Delete UUID
  static Future<String?> deleteUUID(String uuid) async {
    try {
      final result = await removeData('delete-uuid/$uuid');
      return result;
    } catch (e) {
      return 'Error deleting uuid: $e';
    }
  }
}
