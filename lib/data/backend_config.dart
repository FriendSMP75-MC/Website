// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:server_site/data/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const backendUrl = 'https://key-backend-for-friendsmp75-website.onrender.com/';
const accessToken = String.fromEnvironment("ACCESS_TOKEN");

class BackendData {
  
  static User? get user => Supabase.instance.client.auth.currentUser;

  /// Helper to generate headers including the Supabase JWT for RLS
  static Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'X-Access-Token': accessToken,
    };

    if (includeAuth) {
      // Fetch the current JWT session from Supabase
      final String? jwt = Supabase.instance.client.auth.currentSession?.accessToken;
      if (jwt != null) {
        headers['Authorization'] = 'Bearer $jwt';
      }
    }
    return headers;
  }

  // --- Base HTTP Methods ---

  static Future<dynamic> retrieveData(String endpoint, {bool requireAuth = true}) async {
    try {
      final response = await http.get(
        Uri.parse(backendUrl + endpoint),
        headers: _getHeaders(includeAuth: requireAuth),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Backend error: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print('Error Retrieving Data from backend $e');
    }
    return 'Error Retrieving Data';
  }

  static Future<String?> sendData(String endpoint, Map<String, dynamic> content) async {
    try {
      final response = await http.post(
        Uri.parse(backendUrl + endpoint),
        headers: _getHeaders(includeAuth: true),
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

  static Future<String?> removeData(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse(backendUrl + endpoint),
        headers: _getHeaders(includeAuth: true),
      );
      if (response.statusCode == 200) {
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

  // --- Getters ---

  static Future<String?> getOwnerAuthID() async {
    try {
      final data = await retrieveData('check-owner', requireAuth: false);
      if (data != null && data is Map) {
        return data['UUID_ID'] as String?;
      }
    } catch (e) {
      print('Error getting owner auth id: $e');
    }
    return null;
  }

  static Future<List<dynamic>?> getUUID() async {
    try {
      final result = await retrieveData('get-staff-uuids', requireAuth: true);
      if (result is List<dynamic>) return result;
    } catch (e) {
      print('Error when getting uuid $e');
    }
    return null;
  }

  static Future<List<dynamic>?> getAnnouncements() async {
    try {
      final result = await retrieveData('get-announcements', requireAuth: false);
      if (result is List<dynamic>) return result;
    } catch (e) {
      debugPrint('Error when getting announcements: $e');
    }
    return null;
  }

  // --- Senders ---

  static Future<String?> sendUUID(String uuid, String nickname) async {
    return await sendData('add-uuid', {'uuid': uuid, 'nickname': nickname});
  }

  static Future<String?> newAnnouncement(String title, String body) async {
    try {
      final author = SupabaseConfig.getDisplayName(user);
      final authorUUID = SupabaseConfig.getSupabaseUUID(user);
      
      return await sendData('new-announcements', {
        'title': title,
        'body': body,
        'author': author,
        'author_uuid': authorUUID,
      });
    } catch (e) {
      return 'Error: $e';
    }
  }

  static Future<String?> deleteUUID(String uuid) async {
    return await removeData('delete-uuid/$uuid');
  }

  // --- File Upload ---

  static Future<String?> uploadImage({
    required String filename,
    required List<int> imageBytes,
    required String takenDate,
  }) async {
    try {
      final url = Uri.parse('${backendUrl}upload-image');
      final request = http.MultipartRequest('POST', url);

      // Get standard headers
      final headers = _getHeaders(includeAuth: true);
      
      // MultipartRequest handles its own Content-Type, so remove the JSON one
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      // Add text fields
      request.fields['author'] = SupabaseConfig.getDisplayName(user);
      request.fields['author_uuid'] = SupabaseConfig.getSupabaseUUID(user).toString();
      request.fields['taken_date'] = takenDate;

      // Add image file bytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'image', // Must match 'image' in your Flask request.files
          imageBytes,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        print("Backend upload error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error uploading image to backend! $e");
      return null;
    }
  }
}