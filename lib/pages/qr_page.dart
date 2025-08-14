import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  final String networkName;
  const QrScannerPage(this.networkName, {super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcodeDetection(BarcodeCapture capture) {
    if (!isScanning) return;
    final barcode = capture.barcodes.first;

    final value = barcode.rawValue ?? barcode.displayValue;
    if (value != null && mounted) {
      setState(() => isScanning = false);
      Get.back(result: value); // return result using Get.back
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8), // 80% transparent
        elevation: 0,
        title: Text(
          widget.networkName,
          style: const TextStyle(color: Colors.white), // Keep text visible
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {
            if (isScanning) {
              cameraController.stop();
            }
            Get.back();
          },
        ),
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: _handleBarcodeDetection,
      ),
    );
  }
}
