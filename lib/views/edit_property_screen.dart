import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../configs/colors.dart';
import '../controllers/property_controller.dart';
import '../models/property.dart';

class EditPropertyScreen extends StatefulWidget {
  const EditPropertyScreen({super.key});

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final rentController = TextEditingController();

  final PropertyController propertyController = Get.find();

  int propertyIndex = 0;
  String propertyId = '';
  String selectedType = 'Apartment';
  String selectedStatus = 'Available';
  bool propertyFound = true;

  @override
  void initState() {
    super.initState();

    propertyIndex = Get.arguments ?? 0;

    if (propertyController.properties.isEmpty ||
        propertyIndex < 0 ||
        propertyIndex >= propertyController.properties.length) {
      propertyFound = false;
      return;
    }

    final property = propertyController.properties[propertyIndex];

    propertyId = property.id;
    nameController.text = property.name;
    locationController.text = property.location;
    rentController.text = property.rent.toString();
    selectedType = property.type;
    selectedStatus = property.status;
  }

  void updateProperty() {
    if (formKey.currentState!.validate()) {
      final property = Property(
        id: propertyId,
        name: nameController.text.trim(),
        location: locationController.text.trim(),
        rent: double.parse(rentController.text.trim()),
        type: selectedType,
        status: selectedStatus,
      );

      propertyController.updateProperty(propertyIndex, property);

      Get.back();

      Get.snackbar(
        'Success',
        'Property has been updated',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    rentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!propertyFound) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Property')),
        body: const Center(child: Text('Property was not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit Property'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Property name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the property name';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the property location';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: rentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monthly rent',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the monthly rent';
                  }

                  if (double.tryParse(value) == null) {
                    return 'Enter a valid amount';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Property type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Apartment',
                    child: Text('Apartment'),
                  ),
                  DropdownMenuItem(value: 'House', child: Text('House')),
                  DropdownMenuItem(value: 'Office', child: Text('Office')),
                  DropdownMenuItem(value: 'Shop', child: Text('Shop')),
                  DropdownMenuItem(value: 'Land', child: Text('Land')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Property status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Available',
                    child: Text('Available'),
                  ),
                  DropdownMenuItem(value: 'Occupied', child: Text('Occupied')),
                  DropdownMenuItem(
                    value: 'Under Maintenance',
                    child: Text('Under Maintenance'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: updateProperty,
                  child: const Text('Update Property'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
