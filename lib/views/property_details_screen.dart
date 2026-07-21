import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../configs/colors.dart';
import '../configs/routes.dart';
import '../controllers/property_controller.dart';

class PropertyDetailsScreen extends StatelessWidget {
  const PropertyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PropertyController propertyController = Get.find();

    final int index = Get.arguments ?? 0;

    if (propertyController.properties.isEmpty ||
        index < 0 ||
        index >= propertyController.properties.length) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Property Details'),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Property was not found')),
      );
    }

    final property = propertyController.properties[index];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Property Details'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(AppRoutes.editProperty, arguments: index);
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryColor,
                      child: Icon(
                        Icons.home_work,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      property.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    propertyInformation(
                      Icons.numbers,
                      'Property ID',
                      property.id,
                    ),
                    propertyInformation(
                      Icons.location_on,
                      'Location',
                      property.location,
                    ),
                    propertyInformation(
                      Icons.category,
                      'Property Type',
                      property.type,
                    ),
                    propertyInformation(
                      Icons.money,
                      'Monthly Rent',
                      'Ksh ${property.rent.toStringAsFixed(0)}',
                    ),
                    propertyInformation(Icons.info, 'Status', property.status),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget propertyInformation(IconData icon, String title, String value) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
      ),
    );
  }
}
