import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../configs/colors.dart';
import '../configs/routes.dart';
import '../controllers/property_controller.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  late final PropertyController propertyController;

  @override
  void initState() {
    super.initState();

    propertyController = Get.find<PropertyController>();

    propertyController.fetchProperties();
  }

  Future<void> openAddProperty() async {
    final result = await Get.toNamed(AppRoutes.addProperty);

    if (result == true) {
      await propertyController.fetchProperties();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: AppBar(
        title: const Text('Property List'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              propertyController.fetchProperties();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: Obx(() {
        if (propertyController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (propertyController.properties.isEmpty) {
          return const Center(
            child: Text(
              'No properties found in database',
              style: TextStyle(fontSize: 17),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: propertyController.fetchProperties,

          child: ListView.builder(
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
                    '${property.location}\n'
                    'Ksh ${property.rent.toStringAsFixed(0)} per month\n'
                    '${property.type} • ${property.status}',
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
                        showDeleteDialog(index);
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
          ),
        );
      }),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,

        onPressed: openAddProperty,

        child: const Icon(Icons.add),
      ),
    );
  }

  void showDeleteDialog(int index) {
    Get.defaultDialog(
      title: 'Delete Property',

      middleText: 'Are you sure you want to delete this property?',

      textCancel: 'Cancel',

      textConfirm: 'Delete',

      confirmTextColor: Colors.white,

      onConfirm: () {
        Get.back();

        Get.snackbar(
          'Coming next',
          'We will connect Delete to the database next.',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}
