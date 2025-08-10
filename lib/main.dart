import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'db_helper/db_service.dart';
import 'pages/home_page.dart';
import 'controllers/network_controller.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // Init DB and put into GetX
  final dbService = await DBService().init();
  Get.put(dbService, permanent: true);

  Get.put(NetworkController()); // inject controller
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Printer',
      theme: ThemeData(primaryColor: Color.fromRGBO(58, 66, 86, 1.0)),
      home: const HomePage(),
    );
  }
}
