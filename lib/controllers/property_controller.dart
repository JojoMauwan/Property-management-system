import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/property.dart';

class PropertyController extends GetxController {
  final RxList<Property> properties = <Property>[].obs;

  final RxBool isLoading = false.obs;

  String getReadPropertiesUrl() {
    if (kIsWeb) {
      return 'http://localhost/xampp/read_properties.php';
    }

    return 'http://10.0.2.2/xampp/read_properties.php';
  }

  @override
  void onInit() {
    super.onInit();

    fetchProperties();
  }

  Future<void> fetchProperties() async {
    isLoading.value = true;

    try {
      final Uri url = Uri.parse(getReadPropertiesUrl());

      final http.Response response = await http.get(url);

      debugPrint('READ STATUS: ${response.statusCode}');

      debugPrint('READ BODY: ${response.body}');

      if (response.statusCode != 200) {
        properties.clear();
        return;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      final int success = int.tryParse(data['success']?.toString() ?? '0') ?? 0;

      if (success != 1) {
        properties.clear();
        return;
      }

      final List<dynamic> propertyData = data['data'] ?? [];

      final List<Property> loadedProperties = propertyData.map((item) {
        return Property(
          id: item['id'].toString(),
          name: item['property_name']?.toString() ?? '',
          location: item['location']?.toString() ?? '',
          rent: double.tryParse(item['rent_amount']?.toString() ?? '0') ?? 0,
          type: item['property_type']?.toString() ?? '',
          status: item['status']?.toString() ?? '',
        );
      }).toList();

      properties.assignAll(loadedProperties);
    } catch (error) {
      debugPrint('READ PROPERTY ERROR: $error');
    } finally {
      isLoading.value = false;
    }
  }

  void setProperties(List<Property> newProperties) {
    properties.assignAll(newProperties);
  }

  void addProperty(Property property) {
    properties.add(property);
  }

  void updateProperty(int index, Property property) {
    if (index >= 0 && index < properties.length) {
      properties[index] = property;

      properties.refresh();
    }
  }

  void deleteProperty(int index) {
    if (index >= 0 && index < properties.length) {
      properties.removeAt(index);
    }
  }

  void clearProperties() {
    properties.clear();
  }
}
