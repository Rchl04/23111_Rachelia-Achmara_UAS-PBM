// lib/services/api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';

class ApiService {
  // Fungsi POST umum (untuk Login, Register, Create, Update, Delete)
  Future<Map<String, dynamic>> postData(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return {
            'status': 'error',
            'message':
                errorBody['message'] ??
                'Server error code: ${response.statusCode}',
          };
        } catch (e) {
          throw Exception(
            'Gagal terhubung ke server. Status Code: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      throw Exception(
        'Koneksi Gagal: Pastikan server berjalan dan IP benar. Error: $e',
      );
    }
  }

  // Khusus untuk Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await postData(loginUrl, {'email': email, 'password': password});
  }

  // Khusus untuk Register
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    return await postData(registerUrl, {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  // Fungsi GET khusus untuk mendapatkan tugas
  Future<Map<String, dynamic>> getTasks(int userId) async {
    try {
      final response = await http.get(
        // Perhatikan di sini menggunakan getTasksUrl
        Uri.parse('$getTasksUrl?user_id=$userId'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Gagal memuat tugas. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Koneksi Gagal: $e');
    }
  }

  // Fungsi POST untuk membuat tugas
  Future<Map<String, dynamic>> createTask(Map<String, dynamic> taskData) async {
    return await postData(createUrl, taskData);
  }

  // Fungsi POST untuk memperbarui status
  Future<Map<String, dynamic>> updateTaskStatus(
    int taskId,
    String newStatus,
  ) async {
    return await postData(updateStatusUrl, {'id': taskId, 'status': newStatus});
  }

  // Fungsi POST untuk menghapus tugas
  Future<Map<String, dynamic>> deleteTask(int taskId) async {
    return await postData(deleteUrl, {'id': taskId});
  }
}
