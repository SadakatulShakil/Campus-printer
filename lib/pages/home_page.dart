import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_printer/controllers/network_controller.dart';
import 'package:qr_printer/pages/qr_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final NetworkController controller = Get.find();

    void _showCredentialDialog(BuildContext context, String qrData) {
      final nameController = TextEditingController();
      final passwordController = TextEditingController();

      Get.dialog(
        Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          backgroundColor: Colors.transparent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  top: 20,
                ),
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 50),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: Color(0xFFF7F2FA),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxWidth: 400,
                          minWidth: 300,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 40),
                            const Text(
                              "Add Network Credentials",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: nameController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                hintText: 'Enter your username',
                                labelStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                              ),
                              cursorColor: Colors.black87,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: passwordController,
                              textInputAction: TextInputAction.done,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                labelStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                              ),
                              cursorColor: Colors.black,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: () {
                                  final username = nameController.text.trim();
                                  final password = passwordController.text.trim();
                                  controller.addNetwork(qrData, username, password);
                                  Get.back();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0, right: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                    color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add_circle_outline_rounded, color: Colors.black, size: 18),
                                          SizedBox(width: 4),
                                          Text('Save Network',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Color(0xFFF7F2FA),
                              child: Image.asset(
                                'assets/logo/qr_logo.png',
                                width: 50,
                                height: 50,
                              ),
                            ),
                            const Text(
                              "Campus Print App",
                              style: TextStyle(fontSize: 10, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        barrierDismissible: false,
      );
    }

    Future<void> startQrScan(BuildContext context) async {
      final result = await Get.to<String>(() => const QrScannerPage('Scan Network'));

      if (result != null && result.isNotEmpty) {
        _showCredentialDialog(context, result); // ✅ Now it's declared above
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Campus Print', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Obx(() {
            return controller.networks.isNotEmpty
                ? GestureDetector(
              onTap: () => startQrScan(context),
              child: Padding(
                padding: EdgeInsets.only(right: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline_rounded, color: Colors.black, size: 18),
                        SizedBox(width: 4),
                        Text('Add Network',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 16)),
                      ],
                    ),
                  ),
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
                const Text('No network added yet.'),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => startQrScan(context),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_circle_outline_rounded, color: Colors.black, size: 18),
                            SizedBox(width: 4),
                            Text('Add Network',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16)),
                          ],
                        ),
                      ),
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
            final networkName = item.qrData.isNotEmpty ? item.qrData : 'Network ${index + 1}';
            return Card(
              elevation: 8,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Leading Number
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue.shade100,
                        child: Image.asset('assets/icon/list_icon.png', width: 32, height: 32),
                      ),
                      const SizedBox(width: 16),

                      // Title & Subtitle
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final scannedQr = await Get.to<String>(() => QrScannerPage(networkName));
                            if (scannedQr != null && scannedQr.isNotEmpty) {
                              controller.callPrintApi(
                                item.username,
                                item.password,
                                item.qrData,
                                scannedQr,
                              );
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                networkName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${item.qrData}\nUser: ${item.username}',
                                style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Trailing Icons
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          controller.deleteNetwork(item.id ?? 0);
                        },
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.red.shade50,
                          child: const Icon(Icons.delete, size: 18, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
