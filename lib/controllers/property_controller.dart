import 'package:get/get.dart';

import '../models/property.dart';

class PropertyController extends GetxController {
  final RxList<Property> properties = <Property>[].obs;

  // Used later when properties are loaded from MySQL
  void setProperties(List<Property> newProperties) {
    properties.assignAll(newProperties);
  }

  // Keep this because some existing screens may use it.
  void addProperty(Property property) {
    properties.add(property);
  }

  // Required by edit_property_screen.dart
  void updateProperty(int index, Property property) {
    if (index >= 0 && index < properties.length) {
      properties[index] = property;
      properties.refresh();
    }
  }

  // Required by property details/list screens
  void deleteProperty(int index) {
    if (index >= 0 && index < properties.length) {
      properties.removeAt(index);
    }
  }

  void clearProperties() {
    properties.clear();
  }
}
