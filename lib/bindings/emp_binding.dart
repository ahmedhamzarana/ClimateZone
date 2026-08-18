import 'package:get/get.dart';
import 'package:climatezone/controllers/emp_controller.dart';

class EmployeeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmpController>(
      () => EmpController(),
    );
  }
}