import 'package:get/get.dart';
import 'network_controller.dart';

class DocumentsController extends GetxController {
  var selectedDocs = <String>[].obs;
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

  void selectDoc(String doc) {
    if (selectedDocs.contains(doc)) {
      selectedDocs.remove(doc);
    } else {
      selectedDocs.add(doc);
    }
  }

  bool isSelected(String doc) => selectedDocs.contains(doc);
}
