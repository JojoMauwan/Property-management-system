import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../configs/colors.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final rentController = TextEditingController();

  String selectedType = 'Apartment';
  String selectedStatus = 'Available';

  bool isLoading = false;

  String getCreatePropertyUrl() {
    // Flutter Web running on the same computer as XAMPP
    if (kIsWeb) {
      return 'http://localhost/xampp/create_properties.php';
    }

    // Android Emulator
    return 'http://10.0.2.2/xampp/create_properties.php';

    // For a real phone, replace 10.0.2.2 with your PC's IP.
    // Example:
    // return 'http://192.168.1.10/xampp/create_properties.php';
  }

  Future<void> saveProperty() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final String propertyName = nameController.text.trim();
    final String location = locationController.text.trim();
    final String rent = rentController.text.trim();

    setState(() {
      isLoading = true;
    });

    try {
      final Uri url = Uri.parse(getCreatePropertyUrl());

      final http.Response response = await http
          .post(
            url,
            headers: {'Accept': 'application/json'},
            body: {
              'property_name': propertyName,
              'location': location,
              'rent_amount': rent,
              'property_type': selectedType,
              'status': selectedStatus,
            },
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('Create property status: ${response.statusCode}');

      debugPrint('Create property response: ${response.body}');

      if (response.statusCode != 200) {
        Get.snackbar(
          'Server error',
          'Server returned status ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        return;
      }

      if (response.body.trim().isEmpty) {
        Get.snackbar(
          'Server error',
          'The server returned an empty response',
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        Get.snackbar(
          'Response error',
          'Invalid response received from server',
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      final int success =
          int.tryParse(decoded['success']?.toString() ?? '0') ?? 0;

      if (success == 1) {
        Get.snackbar(
          'Success',
          decoded['message']?.toString() ?? 'Property has been added',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        await Future.delayed(const Duration(milliseconds: 500));

        Get.back(result: true);
      } else {
        Get.snackbar(
          'Failed',
          decoded['message']?.toString() ?? 'Could not create property',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on FormatException catch (error) {
      debugPrint('JSON error: $error');

      Get.snackbar(
        'Response error',
        'The server did not return valid JSON',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('Create property error: $error');

      Get.snackbar(
        'Connection error',
        'Could not connect to the property server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: AppBar(
        title: const Text('Add Property'),
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

                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                decoration: const InputDecoration(
                  labelText: 'Monthly rent',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the monthly rent';
                  }

                  final double? rent = double.tryParse(value.trim());

                  if (rent == null) {
                    return 'Enter a valid amount';
                  }

                  if (rent <= 0) {
                    return 'Rent must be greater than zero';
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
                  if (value != null) {
                    setState(() {
                      selectedType = value;
                    });
                  }
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
                  if (value != null) {
                    setState(() {
                      selectedStatus = value;
                    });
                  }
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

                  onPressed: isLoading ? null : saveProperty,

                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Property'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
