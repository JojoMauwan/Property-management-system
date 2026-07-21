import 'package:get/get.dart';

import '../models/property.dart';

class PropertyController extends GetxController {
  var properties = <Property>[].obs;

  @override
  void onInit() {
    super.onInit();

    properties.add(
      Property(
        id: '1',
        name: 'Green View Apartment',
        location: 'Westlands',
        rent: 60000,
        type: 'Apartment',
        status: 'Available',
      ),
    );

    properties.add(
      Property(
        id: '2',
        name: 'Sunrise House',
        location: 'Kilimani',
        rent: 50000,
        type: 'House',
        status: 'Occupied',
      ),
    );
  }

  void addProperty(Property property) {
    properties.add(property);
  }

  void updateProperty(int index, Property property) {
    properties[index] = property;
    properties.refresh();
  }

  void deleteProperty(int index) {
    properties.removeAt(index);
  }
}
