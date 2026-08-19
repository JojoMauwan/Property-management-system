import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

//import '../configs/colors.dart';

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

  InputDecoration fieldDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color.fromARGB(255, 224, 92, 10)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.88),
      labelStyle: const TextStyle(color: Colors.black87),
      hintStyle: TextStyle(color: Colors.grey.shade600),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 224, 92, 10),
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    );
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
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: const Color.fromARGB(255, 224, 92, 10),
        foregroundColor: Colors.white,
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/property_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),

        child: Container(
          width: double.infinity,
          height: double.infinity,

          // Dark overlay so fields/text are easy to see.
          color: Colors.black.withValues(alpha: 0.35),

          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),

              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 750),

                  child: Form(
                    key: formKey,

                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        const Icon(
                          Icons.apartment,
                          size: 85,
                          color: Colors.white,
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Property Management System',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black,
                                offset: Offset(1, 2),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Create your account to manage properties easily',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 8, color: Colors.black),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        TextFormField(
                          controller: firstnameController,
                          decoration: fieldDecoration(
                            label: 'First name',
                            icon: Icons.person,
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
                          decoration: fieldDecoration(
                            label: 'Last name',
                            icon: Icons.person_outline,
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
                          decoration: fieldDecoration(
                            label: 'Email address',
                            icon: Icons.email,
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
                          decoration: fieldDecoration(
                            label: 'Phone number',
                            hint: '0712345678',
                            icon: Icons.phone,
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
                          decoration: fieldDecoration(
                            label: 'Password',
                            icon: Icons.lock,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
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
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                224,
                                92,
                                10,
                              ),
                              foregroundColor: Colors.white,
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: isLoading ? null : registerUser,
                            child: isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        TextButton(
                          onPressed: () {
                            Get.offAllNamed('/login');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Already registered? Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(blurRadius: 8, color: Colors.black),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
