import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../db_helper/database.dart';
import '../db_helper/db_service.dart';
import '../db_helper/models/documents_model.dart';
import '../db_helper/models/network_model.dart';
import 'package:http/http.dart' as http;

class NetworkController extends GetxController {
  final networks = <NetworkModel>[].obs;
  final isCallLoading = false.obs;
  final db = Get.find<DBService>();
  var documents = <Document>[].obs;
  var isLoading = false.obs;

  // var documents = [
  //   "Passport",
  //   "National ID",
  //   "Driving License",
  //   "Birth Certificate",
  //   "Utility Bill"
  // ].obs;

  @override
  void onInit() {
    super.onInit();
    loadNetworks();
  }

  Future<void> fetchDocuments(String baseUrl, String username, String type) async {
    isLoading.value = true;
    try {
      final url = "$baseUrl/api/v1/list_user_print_queue/?username=$username&type=$type";
      final response = await http.get(Uri.parse(url));

      print('Fetching documents from: $url');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        final docResponse = DocumentResponse.fromJson(jsonMap);

        documents.assignAll(docResponse.data); // <-- List<Document>
        isLoading.value = false;
      } else {
        documents.clear();
        isLoading.value = false;
      }
    } catch (e) {
      documents.clear();
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadNetworks() async {
    final list = await db.getAllNetworks();
    networks.assignAll(list);
  }

  Future<void> addNetwork(String qrData, String username, String password) async {
    //call api by base url is qrData then /api/v1/login/
    try {
      isCallLoading.value = true;
      await callPrintApi(username, password, qrData);
    } catch (e) {
      Get.snackbar("Error", "Failed to call print API: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white);
    } finally {
      isCallLoading.value = false;
    }
  }

  Future<void> deleteNetwork(int id) async {
    await db.deleteNetwork(id);
    Get.snackbar("Delete", "The network deleted successfully.", duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade900, colorText: Colors.white);
    await loadNetworks();
  }

  Future<void> callPrintApi(String username, String password, String qrJson) async {
    print('input data: $qrJson, $username, $password');

    try {
      // Decode the JSON string
      final decoded = jsonDecode(qrJson);
      final baseUrl = decoded['NETWORK_URL']; // Extract NETWORK_URL

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('URL: $baseUrl/api/v1/login/');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Save the network
        final network = NetworkModel(
          qrData: qrJson, // keep the full JSON string
          username: username,
          password: password,
        );

        await db.insertNetwork(network);
        await loadNetworks();
        Get.back();
      } else if (response.statusCode == 401) {
        // Unauthorized error
        Get.snackbar("Error", "Unauthorized: Invalid username or password",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade900,
            colorText: Colors.white);
      } else {
        Get.dialog(
          AlertDialog(
            title: const Text('Printer information'),
            content: SelectableText(
              'Scanned QR: $baseUrl\n\n'
                  'Username: $username\n'
                  'Password: $password\n',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // rethrow or handle properly
      Get.snackbar("Error", "Failed to call print API: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white);
    }
  }
}
