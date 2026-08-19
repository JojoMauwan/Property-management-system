import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

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

  bool isDeleting = false;

  @override
  void initState() {
    super.initState();

    propertyController = Get.find<PropertyController>();

    // Load properties from MySQL when screen opens.
    propertyController.fetchProperties();
  }

  // -------------------------------------------------------
  // DELETE API URL
  // -------------------------------------------------------

  String getDeletePropertyUrl() {
    // Flutter Web
    if (kIsWeb) {
      return 'http://localhost/xampp/delete_properties.php';
    }

    // Android emulator
    return 'http://10.0.2.2/xampp/delete_properties.php';

    // Real Android phone:
    //
    // Replace with your PC's IP address.
    //
    // Example:
    // return 'http://192.168.1.10/xampp/delete_properties.php';
  }

  // -------------------------------------------------------
  // OPEN ADD PROPERTY
  // -------------------------------------------------------

  Future<void> openAddProperty() async {
    final dynamic result = await Get.toNamed(AppRoutes.addProperty);

    // Reload database after property was created.
    if (result == true) {
      await propertyController.fetchProperties();
    }
  }

  // -------------------------------------------------------
  // OPEN EDIT PROPERTY
  // -------------------------------------------------------

  Future<void> openEditProperty(int index) async {
    final dynamic result = await Get.toNamed(
      AppRoutes.editProperty,
      arguments: index,
    );

    // Reload from MySQL after editing.
    if (result == true) {
      await propertyController.fetchProperties();
    }
  }

  // -------------------------------------------------------
  // DELETE PROPERTY
  // -------------------------------------------------------

  Future<void> deleteProperty(int index) async {
    // Make sure index exists.
    if (index < 0 || index >= propertyController.properties.length) {
      Get.snackbar(
        'Delete error',
        'Property was not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return;
    }

    // Get property from the controller.
    final property = propertyController.properties[index];

    // IMPORTANT:
    // property.id is the MySQL ID.
    final String propertyId = property.id.toString();

    if (propertyId.isEmpty) {
      Get.snackbar(
        'Delete error',
        'Property ID is missing',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return;
    }

    if (mounted) {
      setState(() {
        isDeleting = true;
      });
    }

    try {
      final Uri url = Uri.parse(getDeletePropertyUrl());

      debugPrint('DELETE URL: $url');
      debugPrint('DELETE PROPERTY ID: $propertyId');

      final http.Response response = await http
          .post(
            url,
            headers: {'Accept': 'application/json'},
            body: {'id': propertyId},
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('DELETE STATUS: ${response.statusCode}');

      debugPrint('DELETE RESPONSE: ${response.body}');

      // Check HTTP status.
      if (response.statusCode != 200) {
        showMessage(
          title: 'Server error',
          message: 'Server returned status ${response.statusCode}',
          success: false,
        );

        return;
      }

      // Check empty response.
      if (response.body.trim().isEmpty) {
        showMessage(
          title: 'Server error',
          message: 'Server returned an empty response',
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
            message: 'Invalid response received from server',
            success: false,
          );

          return;
        }

        data = decoded;
      } on FormatException catch (error) {
        debugPrint('DELETE JSON ERROR: $error');

        showMessage(
          title: 'Response error',
          message: 'Server did not return valid JSON',
          success: false,
        );

        return;
      }

      final int success = int.tryParse(data['success']?.toString() ?? '0') ?? 0;

      // Database deletion succeeded.
      if (success == 1) {
        debugPrint('PROPERTY $propertyId DELETED SUCCESSFULLY');

        // Reload properties from MySQL.
        await propertyController.fetchProperties();

        showMessage(
          title: 'Deleted',
          message:
              data['message']?.toString() ?? 'Property deleted successfully',
          success: true,
        );

        return;
      }

      // PHP returned success = 0.
      showMessage(
        title: 'Delete failed',
        message: data['message']?.toString() ?? 'Could not delete property',
        success: false,
      );
    } on http.ClientException catch (error) {
      debugPrint('DELETE HTTP ERROR: $error');

      showMessage(
        title: 'Connection error',
        message: 'Could not connect to the property server',
        success: false,
      );
    } catch (error) {
      debugPrint('DELETE PROPERTY ERROR: $error');

      showMessage(
        title: 'Delete error',
        message: 'Something went wrong: $error',
        success: false,
      );
    } finally {
      if (mounted) {
        setState(() {
          isDeleting = false;
        });
      }
    }
  }

  // -------------------------------------------------------
  // DELETE CONFIRMATION
  // -------------------------------------------------------

  void showDeleteDialog(int index) {
    if (index < 0 || index >= propertyController.properties.length) {
      return;
    }

    final property = propertyController.properties[index];

    Get.defaultDialog(
      title: 'Delete Property',

      middleText: 'Are you sure you want to delete "${property.name}"?',

      textCancel: 'Cancel',

      textConfirm: 'Delete',

      confirmTextColor: Colors.white,

      buttonColor: Colors.red,

      barrierDismissible: false,

      onConfirm: () async {
        // Close confirmation dialog first.
        Get.back();

        // Then delete from MySQL.
        await deleteProperty(index);
      },
    );
  }

  // -------------------------------------------------------
  // SNACKBAR HELPER
  // -------------------------------------------------------

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

  // -------------------------------------------------------
  // UI
  // -------------------------------------------------------

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

            onPressed: isDeleting
                ? null
                : () async {
                    await propertyController.fetchProperties();
                  },

            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: Obx(() {
        // Loading properties from MySQL.
        if (propertyController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // No properties.
        if (propertyController.properties.isEmpty) {
          return RefreshIndicator(
            onRefresh: propertyController.fetchProperties,

            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),

              children: const [
                SizedBox(height: 200),

                Icon(Icons.home_work_outlined, size: 70, color: Colors.grey),

                SizedBox(height: 15),

                Center(
                  child: Text(
                    'No properties found in database',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            // ------------------------------------------------
            // PROPERTY LIST
            // ------------------------------------------------
            RefreshIndicator(
              onRefresh: propertyController.fetchProperties,

              child: ListView.builder(
                padding: const EdgeInsets.all(10),

                itemCount: propertyController.properties.length,

                itemBuilder: (context, index) {
                  final property = propertyController.properties[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),

                    elevation: 2,

                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primaryColor,

                        child: Icon(Icons.home, color: Colors.white),
                      ),

                      // Property name
                      title: Text(
                        property.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      // Property details
                      subtitle: Text(
                        '${property.location}\n'
                        'Ksh ${property.rent.toStringAsFixed(0)} per month\n'
                        '${property.type} • ${property.status}',
                      ),

                      isThreeLine: true,

                      // Open property details
                      onTap: () async {
                        await Get.toNamed(
                          AppRoutes.propertyDetails,
                          arguments: index,
                        );
                      },

                      // Edit/Delete menu
                      trailing: PopupMenuButton<String>(
                        enabled: !isDeleting,

                        onSelected: (value) async {
                          if (value == 'edit') {
                            await openEditProperty(index);
                          }

                          if (value == 'delete') {
                            showDeleteDialog(index);
                          }
                        },

                        itemBuilder: (context) {
                          return const [
                            PopupMenuItem(
                              value: 'edit',

                              child: Row(
                                children: [
                                  Icon(Icons.edit),

                                  SizedBox(width: 10),

                                  Text('Edit'),
                                ],
                              ),
                            ),

                            PopupMenuItem(
                              value: 'delete',

                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),

                                  SizedBox(width: 10),

                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // ------------------------------------------------
            // DELETE LOADING OVERLAY
            // ------------------------------------------------
            if (isDeleting)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,

                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      }),

      // -----------------------------------------------------
      // ADD PROPERTY BUTTON
      // -----------------------------------------------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,

        foregroundColor: Colors.white,

        onPressed: isDeleting ? null : openAddProperty,

        child: const Icon(Icons.add),
      ),
    );
  }
}
