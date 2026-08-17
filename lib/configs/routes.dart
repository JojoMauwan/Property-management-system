import 'package:get/get.dart';

import '../views/add_property_screen.dart';
import '../views/dashboard.dart';
import '../views/edit_property_screen.dart';
import '../views/home.dart';
import '../views/login.dart';
import '../views/property_details_screen.dart';
import '../views/property_list_screen.dart';
import '../views/registration.dart';

class AppRoutes {
  static const String login = '/login';
  static const String registration = '/register';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String propertyList = '/property-list';
  static const String addProperty = '/add-property';
  static const String propertyDetails = '/property-details';
  static const String editProperty = '/edit-property';
  static const String settings = '/settings';
}

final List<GetPage> routes = [
  GetPage(name: AppRoutes.login, page: () => const Login()),

  GetPage(name: AppRoutes.registration, page: () => const Registration()),

  GetPage(name: AppRoutes.home, page: () => const HomeScreen()),

  GetPage(name: AppRoutes.dashboard, page: () => const Dashboard()),

  GetPage(name: AppRoutes.propertyList, page: () => const PropertyListScreen()),

  GetPage(name: AppRoutes.addProperty, page: () => const AddPropertyScreen()),

  GetPage(
    name: AppRoutes.propertyDetails,
    page: () => const PropertyDetailsScreen(),
  ),

  GetPage(name: AppRoutes.editProperty, page: () => const EditPropertyScreen()),
];
