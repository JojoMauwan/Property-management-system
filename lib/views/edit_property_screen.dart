import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../configs/colors.dart';
import '../controllers/property_controller.dart';

class EditPropertyScreen extends StatefulWidget {
  const EditPropertyScreen({super.key});

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController locationController = TextEditingController();

  final TextEditingController rentController = TextEditingController();

  final PropertyController propertyController = Get.find<PropertyController>();

  int propertyIndex = 0;

  String propertyId = '';

  String selectedType = 'Apartment';
  String selectedStatus = 'Available';

  bool propertyFound = true;
  bool isLoading = false;

  String getUpdatePropertyUrl() {
    if (kIsWeb) {
      return 'http://localhost/xampp/edit_properties.php';
    }

    // Android emulator
    return 'http://10.0.2.2/xampp/edit_properties.php';

    // Real phone:
    // return 'http://YOUR_PC_IP/xampp/update_properties.php';
  }

  @override
  void initState() {
    super.initState();

    final dynamic argument = Get.arguments;

    if (argument is int) {
      propertyIndex = argument;
    } else {
      propertyIndex = 0;
    }

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

  Future<void> updateProperty() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (propertyId.isEmpty) {
      Get.snackbar(
        'Error',
        'Property ID is missing',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return;
    }

    final String propertyName = nameController.text.trim();

    final String location = locationController.text.trim();

    final String rentAmount = rentController.text.trim();

    setState(() {
      isLoading = true;
    });

    try {
      final Uri url = Uri.parse(getUpdatePropertyUrl());

      debugPrint('UPDATE PROPERTY URL: $url');

      debugPrint('PROPERTY ID: $propertyId');

      final http.Response response = await http
          .post(
            url,
            headers: {'Accept': 'application/json'},
            body: {
              'id': propertyId,
              'property_name': propertyName,
              'location': location,
              'rent_amount': rentAmount,
              'property_type': selectedType,
              'status': selectedStatus,
            },
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('UPDATE STATUS: ${response.statusCode}');

      debugPrint('UPDATE BODY: ${response.body}');

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
          'Server returned an empty response',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
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
        /*
         * Reload properties directly
         * from MySQL so the controller
         * contains the latest database
         * values.
         */
        await propertyController.fetchProperties();

        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }

        Get.snackbar(
          'Success',
          decoded['message']?.toString() ?? 'Property updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        await Future.delayed(const Duration(milliseconds: 600));

        Get.back(result: true);

        return;
      }

      Get.snackbar(
        'Update failed',
        decoded['message']?.toString() ?? 'Could not update property',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } on FormatException catch (error) {
      debugPrint('JSON ERROR: $error');

      Get.snackbar(
        'Response error',
        'Server did not return valid JSON',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (error) {
      debugPrint('UPDATE PROPERTY ERROR: $error');

      Get.snackbar(
        'Error',
        'Could not update property: $error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted && isLoading) {
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
    if (!propertyFound) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Property'),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              /*
              |--------------------------------------------------------------------------
              | Property ID
              |--------------------------------------------------------------------------
              */
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Property ID: $propertyId',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              /*
              |--------------------------------------------------------------------------
              | Property Name
              |--------------------------------------------------------------------------
              */
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

              /*
              |--------------------------------------------------------------------------
              | Location
              |--------------------------------------------------------------------------
              */
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

              /*
              |--------------------------------------------------------------------------
              | Rent
              |--------------------------------------------------------------------------
              */
              TextFormField(
                controller: rentController,

                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                decoration: const InputDecoration(
                  labelText: 'Monthly rent',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments),
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

              /*
              |--------------------------------------------------------------------------
              | Property Type
              |--------------------------------------------------------------------------
              */
              DropdownButtonFormField<String>(
                value: selectedType,

                decoration: const InputDecoration(
                  labelText: 'Property type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
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

                onChanged: isLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            selectedType = value;
                          });
                        }
                      },
              ),

              const SizedBox(height: 15),

              /*
              |--------------------------------------------------------------------------
              | Status
              |--------------------------------------------------------------------------
              */
              DropdownButtonFormField<String>(
                value: selectedStatus,

                decoration: const InputDecoration(
                  labelText: 'Property status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
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

                onChanged: isLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            selectedStatus = value;
                          });
                        }
                      },
              ),

              const SizedBox(height: 25),

              /*
              |--------------------------------------------------------------------------
              | Update Button
              |--------------------------------------------------------------------------
              */
              SizedBox(
                height: 50,

                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),

                  onPressed: isLoading ? null : updateProperty,

                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),

                  label: Text(isLoading ? 'Updating...' : 'Update Property'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
