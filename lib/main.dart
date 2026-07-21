import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'configs/routes.dart';
import 'controllers/property_controller.dart';

void main() {
  Get.put(PropertyController());

  runApp(const PropertyApp());
}

class PropertyApp extends StatelessWidget {
  const PropertyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Property Management System',
      initialRoute: AppRoutes.registration,
      getPages: routes,
    );
  }
}
