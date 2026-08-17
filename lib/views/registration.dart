import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../configs/colors.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final formKey = GlobalKey<FormState>();

  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;

  String getRegistrationUrl() {
    // Flutter Web on same PC as XAMPP
    if (kIsWeb) {
      return 'http://localhost/xampp/registration.php';
    }

    // Android emulator
    return 'http://10.0.2.2/xampp/registration.php';

    // Real phone:
    // return 'http://YOUR_PC_IP/xampp/registration.php';
  }

  Future<void> registerUser() async {
    debugPrint('REGISTER BUTTON CLICKED');

    if (!formKey.currentState!.validate()) {
      return;
    }

    final String firstname = firstnameController.text.trim();
    final String lastname = lastnameController.text.trim();
    final String email = emailController.text.trim();
    final String phone = phoneController.text.trim();
    final String password = passwordController.text.trim();

    setState(() {
      isLoading = true;
    });

    try {
      final Uri url = Uri.parse(getRegistrationUrl());

      debugPrint('Registration URL: $url');
      debugPrint('firstname: $firstname');
      debugPrint('lastname: $lastname');
      debugPrint('email: $email');
      debugPrint('phone: $phone');

      final http.Response response = await http
          .post(
            url,
            headers: {'Accept': 'application/json'},
            body: {
              'firstname': firstname,
              'lastname': lastname,
              'email': email,
              'phone': phone,
              'password': password,
            },
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

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
        );
        return;
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        Get.snackbar(
          'Response error',
          'Invalid response from server',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final int success =
          int.tryParse(decoded['success']?.toString() ?? '0') ?? 0;

      if (success == 1) {
        Get.snackbar(
          'Registration successful',
          decoded['message']?.toString() ?? 'Account created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        firstnameController.clear();
        lastnameController.clear();
        emailController.clear();
        phoneController.clear();
        passwordController.clear();

        await Future.delayed(const Duration(milliseconds: 700));

        // After successful DB insert, go to login
        Get.offAllNamed('/login');
      } else {
        Get.snackbar(
          'Registration failed',
          decoded['message']?.toString() ?? 'Could not create account',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on FormatException catch (error) {
      debugPrint('JSON error: $error');

      Get.snackbar(
        'Response error',
        'Server did not return valid JSON',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('Registration error: $error');

      Get.snackbar(
        'Connection error',
        'Could not connect to registration server',
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
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: const Color.fromARGB(255, 224, 92, 10),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const Icon(
                Icons.apartment,
                size: 80,
                color: Color.fromRGBO(224, 92, 10, 1),
              ),

              const SizedBox(height: 20),

              const Text(
                'Property Management System',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              TextFormField(
                controller: firstnameController,
                decoration: const InputDecoration(
                  labelText: 'First name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter your first name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: lastnameController,
                decoration: const InputDecoration(
                  labelText: 'Last name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter your last name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter your email';
                  }

                  if (!GetUtils.isEmail(value.trim())) {
                    return 'Enter a valid email address';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: '0712345678',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter your phone number';
                  }

                  if (value.trim().length < 10) {
                    return 'Enter a valid phone number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: passwordController,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    icon: Icon(
                      showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 4) {
                    return 'Password should have at least 4 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 224, 92, 10),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isLoading ? null : registerUser,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Register'),
                ),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  Get.offAllNamed('/login');
                },
                child: const Text('Already registered? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
