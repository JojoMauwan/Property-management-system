import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../configs/colors.dart';
import '../configs/routes.dart';
import '../controllers/property_controller.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final PropertyController propertyController = Get.find();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Property Dashboard'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Get.offAllNamed(AppRoutes.registration);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Obx(
                () => Column(
                  children: [
                    const Icon(Icons.home_work, color: Colors.white, size: 55),
                    const SizedBox(height: 10),
                    const Text(
                      'Property Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total properties: ${propertyController.properties.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  dashboardCard(
                    title: 'Property List',
                    icon: Icons.list,
                    onTap: () {
                      Get.toNamed(AppRoutes.propertyList);
                    },
                  ),
                  dashboardCard(
                    title: 'Add Property',
                    icon: Icons.add_home,
                    onTap: () {
                      Get.toNamed(AppRoutes.addProperty);
                    },
                  ),
                  dashboardCard(
                    title: 'Property Details',
                    icon: Icons.description,
                    onTap: () {
                      if (propertyController.properties.isEmpty) {
                        showNoPropertyMessage();
                      } else {
                        Get.toNamed(AppRoutes.propertyDetails, arguments: 0);
                      }
                    },
                  ),
                  dashboardCard(
                    title: 'Edit Property',
                    icon: Icons.edit,
                    onTap: () {
                      if (propertyController.properties.isEmpty) {
                        showNoPropertyMessage();
                      } else {
                        Get.toNamed(AppRoutes.editProperty, arguments: 0);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: AppColors.primaryColor),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void showNoPropertyMessage() {
    Get.snackbar(
      'No property',
      'Please add a property first',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
