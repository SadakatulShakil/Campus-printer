import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../db_helper/models/documents_model.dart';
import 'network_controller.dart';
import 'package:http/http.dart' as http;

class DocumentsController extends GetxController {
  var selectedDocs = <Document>[].obs;
  var selectAll = false.obs;
  var showDocs = false.obs;
  var remainingTime = 20.obs;

  void toggleSelectAll() {
    selectAll.value = !selectAll.value;
    showDocs.value = selectAll.value;

    if (selectAll.value) {
      selectedDocs.assignAll(Get.find<NetworkController>().documents);
    } else {
      selectedDocs.clear();
    }
  }

  void selectDoc(Document doc) {
    if (selectedDocs.contains(doc)) {
      selectedDocs.remove(doc);
    } else {
      selectedDocs.add(doc);
    }
  }



  bool isSelected(Document doc) => selectedDocs.contains(doc);

  Future<void> printDocuments(
      String result,
      String qrData,
      String username,
      String password,
      List<int> docIds,
      ) async {
    // Show loading dialog
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                "Printing started, please wait...",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Decode the JSON string
      final decoded = jsonDecode(qrData);
      final baseUrl = decoded['NETWORK_URL']; // Extract NETWORK_URL
      final printer_id = decoded['PRINTER_UID']; // Extract PRINTER_UID

      final url = Uri.parse('$baseUrl/api/v1/authorize_print/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          "printer_uid": printer_id,
          "job_ids": docIds
        }),
      );

      Get.back(); // close loading dialog

      print('URL: $url');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      //body data
      print('api body: userName: $username, password: $password, printer_uid: $printer_id, job_ids: $docIds');

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Documents sent to printer successfully",
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to print documents (${response.statusCode})",
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.back(); // close loading dialog if error
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
