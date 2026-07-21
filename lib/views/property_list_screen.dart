import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../configs/colors.dart';
import '../configs/routes.dart';
import '../controllers/property_controller.dart';

class PropertyListScreen extends StatelessWidget {
  const PropertyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PropertyController propertyController = Get.find();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Property List'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (propertyController.properties.isEmpty) {
          return const Center(
            child: Text(
              'No properties have been added',
              style: TextStyle(fontSize: 17),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: propertyController.properties.length,
          itemBuilder: (context, index) {
            final property = propertyController.properties[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryColor,
                  child: Icon(Icons.home, color: Colors.white),
                ),
                title: Text(property.name),
                subtitle: Text(
                  '${property.location}\nKsh ${property.rent.toStringAsFixed(0)} per month',
                ),
                isThreeLine: true,
                onTap: () {
                  Get.toNamed(AppRoutes.propertyDetails, arguments: index);
                },
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Get.toNamed(AppRoutes.editProperty, arguments: index);
                    }

                    if (value == 'delete') {
                      showDeleteDialog(propertyController, index);
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ];
                  },
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Get.toNamed(AppRoutes.addProperty);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void showDeleteDialog(PropertyController propertyController, int index) {
    Get.defaultDialog(
      title: 'Delete Property',
      middleText: 'Are you sure you want to delete this property?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        propertyController.deleteProperty(index);
        Get.back();

        Get.snackbar(
          'Deleted',
          'The property has been deleted',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}
