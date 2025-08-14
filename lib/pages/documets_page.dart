import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_printer/pages/qr_page.dart';
import '../controllers/documents_controller.dart';
import '../controllers/network_controller.dart';

class DocumentsPage extends StatelessWidget {
  final String networkName;
  final String qrData;
  final String username;
  final String password;

  DocumentsPage({
    super.key,
    required this.networkName,
    required this.qrData,
    required this.username,
    required this.password,
  });

  void _showPrintingDialog() {
   DocumentsController docController = Get.find<DocumentsController>();
    Timer? timer;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
            if (docController.remainingTime > 0) {
              setState(() => docController.remainingTime--);
            } else {
              t.cancel();
            }
          });

          return AlertDialog(
            title: const Text("Documents are printing"),
            content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                docController.remainingTime.value == 0?
                Text('Success !')
                :Text('Please wait...'),
                const SizedBox(height: 12),
                docController.remainingTime.value == 0?
                const Icon(Icons.check_circle, color: Colors.green, size: 48)
                :LinearProgressIndicator(value: (20 - docController.remainingTime.value) / 20),
                const SizedBox(height: 8),
                docController.remainingTime.value == 0?
                Text("Print completed"):
                Text("${docController.remainingTime} seconds remaining"),
                if (docController.remainingTime.value == 0)
                  ElevatedButton(
                    onPressed: () {
                      timer?.cancel();
                      Get.back();
                    },
                    child: const Text("OK"),
                  ),
              ],
            )),
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _goToScanner(String docs) async {
    final result = await Get.to<String>(() => QrScannerPage(docs));
    if (result != null && result.isNotEmpty) {
      _showPrintingDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final networkController = Get.put(NetworkController());
    final docController = Get.put(DocumentsController());

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Documents', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () =>
                docController.selectedDocs.isNotEmpty
                    ? Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () {
                          _goToScanner(docController.selectedDocs.join(", "));
                        },
                        child: const Text(
                          "Print All",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(
            () => CheckboxListTile(
              title: const Text(
                "Select All",
                style: TextStyle(color: Colors.white),
              ),
              value: docController.selectAll.value,
              onChanged: (_) => docController.toggleSelectAll(),
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: networkController.documents.length,
              itemBuilder: (context, index) {
                final doc = networkController.documents[index];

                return Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          doc,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing:
                            docController.selectAll.value
                                ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                                : const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white70,
                                ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor:
                            docController.selectAll.value
                                ? Colors.white24
                                : Colors.transparent,
                        onTap: () {
                          if (docController.selectAll.value) {
                            Get.snackbar(
                              'Warning',
                              'You select all documents, please unselect them to print individually or print all.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red.withOpacity(0.8),
                              colorText: Colors.white,
                            );
                          } else {
                            _goToScanner(doc);
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
