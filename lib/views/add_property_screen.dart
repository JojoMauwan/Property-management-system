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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController rentController = TextEditingController();

  String selectedType = 'Apartment';
  String selectedStatus = 'Available';

  bool isLoading = false;

  String getCreatePropertyUrl() {
    if (kIsWeb) {
      return 'http://localhost/xampp/create_properties.php';
    }

    // Android emulator
    return 'http://10.0.2.2/xampp/create_properties.php';

    // For a real phone, use your computer's local IP address instead.
    // Example:
    // return 'http://192.168.1.10/xampp/create_properties.php';
  }

  Future<void> saveProperty() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final String propertyName = nameController.text.trim();
    final String location = locationController.text.trim();
    final String rentAmount = rentController.text.trim();

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final Uri url = Uri.parse(getCreatePropertyUrl());

      debugPrint('CREATE PROPERTY URL: $url');
      debugPrint('Property name: $propertyName');
      debugPrint('Location: $location');
      debugPrint('Rent: $rentAmount');
      debugPrint('Type: $selectedType');
      debugPrint('Status: $selectedStatus');

      final http.Response response = await http
          .post(
            url,
            headers: {'Accept': 'application/json'},
            body: {
              'property_name': propertyName,
              'location': location,
              'rent_amount': rentAmount,
              'property_type': selectedType,
              'status': selectedStatus,
            },
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('HTTP STATUS: ${response.statusCode}');
      debugPrint('SERVER RESPONSE: ${response.body}');

      if (response.statusCode != 200) {
        showMessage(
          title: 'Server error',
          message: 'Server returned status ${response.statusCode}',
          success: false,
        );
        return;
      }

      if (response.body.trim().isEmpty) {
        showMessage(
          title: 'Server error',
          message: 'The server returned an empty response',
          success: false,
        );
        return;
      }

      Map<String, dynamic> data;

      try {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is! Map<String, dynamic>) {
          showMessage(
            title: 'Response error',
            message: 'The server returned an invalid response',
            success: false,
          );
          return;
        }

        data = decoded;
      } on FormatException catch (error) {
        debugPrint('JSON ERROR: $error');

        showMessage(
          title: 'Response error',
          message: 'The server did not return valid JSON',
          success: false,
        );
        return;
      }

      final int success = int.tryParse(data['success']?.toString() ?? '0') ?? 0;

      if (success != 1) {
        showMessage(
          title: 'Property not saved',
          message: data['message']?.toString() ?? 'Could not create property',
          success: false,
        );
        return;
      }

      debugPrint('PROPERTY SAVED SUCCESSFULLY');

      if (data['data'] != null) {
        debugPrint('SAVED PROPERTY DATA: ${data['data']}');
      }

      // Clear form after successful database insert.
      nameController.clear();
      locationController.clear();
      rentController.clear();

      if (mounted) {
        setState(() {
          selectedType = 'Apartment';
          selectedStatus = 'Available';
          isLoading = false;
        });
      }

      showMessage(
        title: 'Success',
        message: data['message']?.toString() ?? 'Property created successfully',
        success: true,
      );

      // Small delay so the user sees the success message.
      await Future.delayed(const Duration(milliseconds: 700));

      // Return to the previous page only if there is one.
      if (Get.key.currentState?.canPop() == true) {
        Get.back(result: true);
      }
    } on http.ClientException catch (error) {
      debugPrint('HTTP CLIENT ERROR: $error');

      showMessage(
        title: 'Connection error',
        message: 'Could not connect to the property server',
        success: false,
      );
    } catch (error) {
      debugPrint('CREATE PROPERTY ERROR: $error');

      showMessage(
        title: 'Error',
        message: 'Something went wrong: $error',
        success: false,
      );
    } finally {
      if (mounted && isLoading) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage({
    required String title,
    required String message,
    required bool success,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: success ? Colors.green : Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
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

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Form(
            key: formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                const Icon(Icons.add_home_work, size: 70),

                const SizedBox(height: 15),

                const Text(
                  'Create New Property',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 25),

                TextFormField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,

                  decoration: const InputDecoration(
                    labelText: 'Property name',
                    hintText: 'Example: The Burbs',
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
                  textInputAction: TextInputAction.next,

                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Example: Athi River',
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

                  textInputAction: TextInputAction.done,

                  decoration: const InputDecoration(
                    labelText: 'Monthly rent',
                    hintText: 'Example: 20000',
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

                DropdownButtonFormField<String>(
                  initialValue: selectedType,

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

                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,

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
                    DropdownMenuItem(
                      value: 'Occupied',
                      child: Text('Occupied'),
                    ),
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

                SizedBox(
                  height: 50,

                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),

                    onPressed: isLoading ? null : saveProperty,

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

                    label: Text(
                      isLoading ? 'Saving Property...' : 'Save Property',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
