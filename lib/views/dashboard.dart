import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../configs/colors.dart';
import '../configs/routes.dart';
import '../controllers/property_controller.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final PropertyController propertyController =
        Get.find<PropertyController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: AppBar(
        title: const Text('Property Dashboard'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,

        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              Get.offAllNamed(AppRoutes.login);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              /*
              |--------------------------------------------------------------------------
              | Dashboard Header
              |--------------------------------------------------------------------------
              */
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Obx(
                  () => Column(
                    children: [
                      const Icon(
                        Icons.home_work,
                        color: Colors.white,
                        size: 55,
                      ),

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
                        'Total properties: '
                        '${propertyController.properties.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /*
              |--------------------------------------------------------------------------
              | Dashboard Menu
              |--------------------------------------------------------------------------
              */
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,

                  children: [
                    /*
                    |--------------------------------------------------------------------------
                    | Property List
                    |--------------------------------------------------------------------------
                    */
                    dashboardCard(
                      title: 'Property List',
                      icon: Icons.list_alt,

                      onTap: () {
                        Get.toNamed(AppRoutes.propertyList);
                      },
                    ),

                    /*
                    |--------------------------------------------------------------------------
                    | Add Property
                    |--------------------------------------------------------------------------
                    */
                    dashboardCard(
                      title: 'Add Property',
                      icon: Icons.add_home_work,

                      onTap: () async {
                        final result = await Get.toNamed(AppRoutes.addProperty);

                        if (result == true) {
                          Get.snackbar(
                            'Property saved',
                            'Property was saved successfully',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );

                          /*
                           * Later, when we implement
                           * read_properties.php,
                           * we will refresh the
                           * PropertyController here.
                           */
                        }
                      },
                    ),

                    /*
                    |--------------------------------------------------------------------------
                    | Property Details
                    |--------------------------------------------------------------------------
                    */
                    dashboardCard(
                      title: 'Property Details',
                      icon: Icons.description,

                      onTap: () {
                        if (propertyController.properties.isEmpty) {
                          showNoPropertyMessage();
                          return;
                        }

                        Get.toNamed(AppRoutes.propertyDetails, arguments: 0);
                      },
                    ),

                    /*
                    |--------------------------------------------------------------------------
                    | Edit Property
                    |--------------------------------------------------------------------------
                    */
                    dashboardCard(
                      title: 'Edit Property',
                      icon: Icons.edit,

                      onTap: () {
                        if (propertyController.properties.isEmpty) {
                          showNoPropertyMessage();
                          return;
                        }

                        Get.toNamed(AppRoutes.editProperty, arguments: 0);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dashboardCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: InkWell(
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Icon(icon, size: 46, color: AppColors.primaryColor),

              const SizedBox(height: 12),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showNoPropertyMessage() {
    Get.snackbar(
      'No property',
      'Open the Property List or add a property first',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }
}
