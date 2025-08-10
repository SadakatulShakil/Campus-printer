import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../db_helper/database.dart';
import '../db_helper/db_service.dart';
import '../db_helper/models/network_model.dart';
import 'package:http/http.dart' as http;

class NetworkController extends GetxController {
  final networks = <NetworkModel>[].obs;
  final isCallLoading = false.obs;
  final db = Get.find<DBService>();


  @override
  void onInit() {
    super.onInit();
    loadNetworks();
  }

  Future<void> loadNetworks() async {
    final list = await db.getAllNetworks();
    networks.assignAll(list);
  }

  Future<void> addNetwork(String qrData, String username, String password) async {
    final network = NetworkModel(
      qrData: qrData,
      username: username,
      password: password,
    );
    await db.insertNetwork(network);
    await loadNetworks();
  }

  Future<void> deleteNetwork(int id) async {
    await db.deleteNetwork(id);
    Get.snackbar("Delete", "The network deleted successfully.", duration: const Duration(seconds: 1));
    await loadNetworks();
  }

  Future<void> callPrintApi(String username, String password, String idAddress, String document) async {
    try {
      final response = await http.post(
        Uri.parse('http://$idAddress/print'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'document': document,
        }),
      );

      if (response.statusCode == 200) {
        Get.dialog(
          AlertDialog(
            title: Text('Printer information'),
            content: SelectableText(
              'Scanned QR: $document\n\n'
                  'Saved QR: $username\n'
                  'Username: $password\n'
                  'Password: $idAddress',
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
      else {
        Get.dialog(
          AlertDialog(
            title: Text('Printer information'),
            content: SelectableText(
              'Scanned QR: $document\n\n'
                  'Saved QR: $username\n'
                  'Username: $password\n'
                  'Password: $idAddress',
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
      /// here need write rethrow logic
      print("Error calling print API: $e");
      Get.dialog(
        AlertDialog(
          title: Text('Printer information'),
          content: SelectableText(
            'Scanned QR: $document\n\n'
                'Saved QR: $username\n'
                'Username: $password\n'
                'Password: $idAddress',
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
  }

}
