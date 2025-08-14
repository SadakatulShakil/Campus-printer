import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_printer/controllers/network_controller.dart';
import 'package:qr_printer/pages/qr_page.dart';
import 'credential_page.dart';
import 'documets_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final NetworkController controller = Get.find();

    Future<void> startQrScan(BuildContext context) async {
      final startTime = DateTime.now();
      final result = await Get.to<String>(() => const QrScannerPage('Scan Network'));
      final endTime = DateTime.now();
      final scanDuration = endTime.difference(startTime).inMilliseconds;
      debugPrint("⏱ QR scan took $scanDuration ms (${scanDuration / 1000} seconds)");

      if (result != null && result.isNotEmpty) {
        Get.to(() => AddNetworkPage(
          qrData: result,
          onNetworkAdded: () {
            controller.networks(); // refresh method from controller
          },
        ));
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark mode background
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212), // Match scaffold background
        elevation: 0,
        title: const Text(
          'Campus Print',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() {
            return controller.networks.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                onPressed: () => startQrScan(context),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                label: const Text(
                  'Add Network',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            )
                : const SizedBox();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.networks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No network added yet.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => startQrScan(context),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('Add Network'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.networks.length,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          itemBuilder: (context, index) {
            final item = controller.networks[index];
            final networkName =
            item.qrData.isNotEmpty ? item.qrData : 'Network ${index + 1}';
            return Card(
              color: Colors.grey[850], // Dark card color
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Leading Icon
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        'assets/icon/list_icon.png',
                        width: 28,
                        height: 28,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Title & Subtitle
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          // final scannedQr = await Get.to<String>(
                          //         () => QrScannerPage(networkName));
                          // if (scannedQr != null && scannedQr.isNotEmpty) {
                          //   controller.callPrintApi(
                          //     item.username,
                          //     item.password,
                          //     item.qrData,
                          //     scannedQr,
                          //   );
                          // }
                          Get.to(DocumentsPage(
                            networkName: networkName,
                            qrData: item.qrData,
                            username: item.username,
                            password: item.password,
                          ));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              networkName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${item.qrData}\nUser: ${item.username}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Delete Button
                    GestureDetector(
                      onTap: () {
                        controller.deleteNetwork(item.id ?? 0);
                      },
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.red.shade900,
                        child: const Icon(Icons.delete,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
