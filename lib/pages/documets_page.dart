import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_printer/pages/qr_page.dart';
import '../controllers/documents_controller.dart';
import '../controllers/network_controller.dart';
import 'package:intl/intl.dart';

class DocumentsPage extends StatefulWidget {
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

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {

  final networkController = Get.put(NetworkController());
  final docController = Get.put(DocumentsController());

  Future<void> _goToScanner(String docs, List<int> ids) async {
    final result = await Get.to<String>(() => QrScannerPage(docs));
    if (result != null && result.isNotEmpty) {
      //Call print api
      docController.printDocuments(result, widget.qrData, widget.username, widget.password, ids);
    }
  }

  @override
  void initState() {
    super.initState();
    // Load "pending" once when the page opens
    networkController.fetchDocuments(widget.networkName, widget.username, "Pending");
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                  () => docController.selectedDocs.isNotEmpty
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
                    _goToScanner('You selected ${docController.selectedDocs.length} documents',
                      docController.selectedDocs.map((d) => d.id).toList());
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
          bottom: TabBar(
            indicatorColor: Colors.white,
            onTap: (index) {
              if (index == 0) {
                networkController.fetchDocuments(widget.networkName, widget.username, "Pending");
              }else if(index == 1){
                networkController.fetchDocuments(widget.networkName, widget.username, "SentToPrinter");
              } else {
                networkController.fetchDocuments(widget.networkName, widget.username, "All");
              }
            },
            tabs: const [
              Tab(text: "Pending"),
              Tab(text: "Printed"),
              Tab(text: "All"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Obx(() => _buildDocsList(networkController, docController)),
            Obx(() => _buildDocsList(networkController, docController)),
            Obx(() => _buildDocsList(networkController, docController)),
          ],
        ),
      ),
    );
}

  Widget _buildDocsList(
      NetworkController networkController, DocumentsController docController) {
    if (networkController.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (networkController.documents.isEmpty) {
      return const Center(
          child: Text("No documents found", style: TextStyle(color: Colors.white)));
    }

    return Column(
      children: [
        Obx(
              () => CheckboxListTile(
            title: const Text("Select All", style: TextStyle(color: Colors.white)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(doc.file.split('/').last, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        "Status: ${doc.status}\nCreated: ${DateFormat('MMM dd, yyyy – hh:mm a').format(doc.createdAt)}",
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      trailing: docController.selectAll.value
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.arrow_forward_ios,
                          color: Colors.white70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: docController.selectAll.value
                          ? Colors.white24
                          : Colors.transparent,
                      onTap: () {
                        if (docController.selectAll.value) {
                          Get.snackbar(
                            'Warning',
                            'You selected all documents, please unselect to print individually or print all.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.8),
                            colorText: Colors.white,
                          );
                        } else {
                          _goToScanner(doc.file.split('/').last+' is printing', [doc.id]);
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
    );
  }
}
