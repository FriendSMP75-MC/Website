// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:http_parser/http_parser.dart'; // Required for MediaType

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
      final String? jwt =
          Supabase.instance.client.auth.currentSession?.accessToken;
      if (jwt != null) {
        headers['Authorization'] = 'Bearer $jwt';
      }
    }
    return headers;
  }

  // --- Base HTTP Methods ---

  static Future<dynamic> retrieveData(
    String endpoint, {
    bool requireAuth = true,
  }) async {
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

  static Future<String?> sendData(
    String endpoint,
    Map<String, dynamic> content,
  ) async {
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
      final result = await retrieveData(
        'get-announcements',
        requireAuth: false,
      );
      if (result is List<dynamic>) return result;
    } catch (e) {
      debugPrint('Error when getting announcements: $e');
    }
    return null;
  }

  /// Retrieves image metadata (author, taken date, etc.)
  static Future<List<dynamic>?> getGalleryData() async {
    try {
      final result = await retrieveData('get-gallery-data', requireAuth: false);
      if (result is List<dynamic>) return result;
    } catch (e) {
      debugPrint('Error fetching gallery data: $e');
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

  // --- UPLOAD METHOD (WEB ONLY) ---
  /// Uses imageBytes because 'path' is null on Web.
  /// Sends as Multipart/form-data to satisfy Flask/Waitress.
  static Future<String?> uploadImage({
    required List<int> imageBytes,
    required String filename,
    required String takenDate,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final headers = _getHeaders(includeAuth: true);
      headers.remove('Content-Type');

      final ext = filename.split('.').last.toLowerCase();
      final mimeType = (ext == 'jpg' || ext == 'jpeg') ? 'jpeg' : 'png';

      final dioClient = dio.Dio(
        dio.BaseOptions(
          baseUrl: backendUrl,
          headers: headers,
          responseType: dio.ResponseType.plain,
        ),
      );

      final formData = dio.FormData.fromMap({
        'author': SupabaseConfig.getDisplayName(user),
        'author_uuid': SupabaseConfig.getSupabaseUUID(user).toString(),
        'taken_date': takenDate,
        'image': dio.MultipartFile.fromBytes(
          imageBytes,
          filename: filename,
          contentType: MediaType('image', mimeType),
        ),
      });

      final response = await dioClient.post(
        'upload-image',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data?.toString();
      }

      print('Backend upload error: ${response.statusCode} ${response.data}');
      return null;
    } catch (e) {
      print("Upload exception: $e");
      return null;
    }
  }

  static Future<String?> addMemoryRequest({
    required List<int> imageBytes,
    required String filename,
    required String uuid,
    required String displayName,
    required String timeTaken,
    String? title,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final normalizedTitle = title?.trim() ?? '';
      if (normalizedTitle.isEmpty) {
        print('Memory request validation error: title is required.');
        return null;
      }

      final headers = _getHeaders(includeAuth: true);
      headers.remove('Content-Type');
      final ext = filename.split('.').last.toLowerCase();
      final mimeType = (ext == 'jpg' || ext == 'jpeg') ? 'jpeg' : 'png';

      final dioClient = dio.Dio(
        dio.BaseOptions(
          baseUrl: backendUrl,
          headers: headers,
          responseType: dio.ResponseType.plain,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final formDataMap = <String, dynamic>{
        'uuid': uuid,
        'author_uuid': uuid,
        'display_name': displayName,
        'displayname': displayName,
        'author': displayName,
        'time_taken': timeTaken,
        'date_taken': timeTaken,
        'taken_date': timeTaken,
        'title': normalizedTitle,
        'image': dio.MultipartFile.fromBytes(
          imageBytes,
          filename: filename,
          contentType: MediaType('image', mimeType),
        ),
      };

      final response = await dioClient.post(
        'memory-request-add',
        data: dio.FormData.fromMap(formDataMap),
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data?.toString();
      }

      print(
        'Memory request upload error: ${response.statusCode} ${response.data}',
      );
      return null;
    } catch (e) {
      if (e is dio.DioException) {
        print(
          'Memory request upload exception: ${e.response?.statusCode} ${e.response?.data}',
        );
      } else {
        print('Memory request upload exception: $e');
      }
      return null;
    }
  }

  static Future<String?> powerAction(String action) async {
    try {
      return await sendData('server-$action', {'value': null});
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> serverStatus() async {
    try {
      final response = await retrieveData('server-status');
      if (response == null) return null;
      if (response is Map<String, dynamic>) return response;
      return null;
    } catch (e) {
      return null;
    }
  }
}


