import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/configs/colors.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GetStorage store = GetStorage();

  bool isLoading = false;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();

    phoneController.text = store.read('username') ?? '';
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String getLoginUrl() {
    // Flutter Web running on the same Windows computer as XAMPP
    if (kIsWeb) {
      return 'http://localhost/xampp/login.php';
    }

    // Android Emulator
    //
    // If you are using a REAL PHONE, replace 10.0.2.2
    // with your computer's IP address, for example:
    //
    // return 'http://192.168.1.10/xampp/login.php';

    return 'http://10.0.2.2/xampp/login.php';
  }

  Future<void> loginUser() async {
    final String phone = phoneController.text.trim();
    final String password = passwordController.text.trim();

    if (phone.isEmpty) {
      Get.snackbar(
        'Missing phone number',
        'Please enter your phone number.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (password.isEmpty) {
      Get.snackbar(
        'Missing password',
        'Please enter your password.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final Uri url = Uri.parse(
        getLoginUrl(),
      ).replace(queryParameters: {'phone': phone, 'password': password});

      debugPrint('Login URL: $url');

      final http.Response response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode != 200) {
        Get.snackbar(
          'Server error',
          'Server returned HTTP ${response.statusCode}.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (response.body.trim().isEmpty) {
        Get.snackbar(
          'Server error',
          'The server returned an empty response.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final dynamic decodedResponse = jsonDecode(response.body);

      if (decodedResponse is! Map<String, dynamic>) {
        Get.snackbar(
          'Response error',
          'Invalid response received from server.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final Map<String, dynamic> data = decodedResponse;

      final int success = int.tryParse(data['success']?.toString() ?? '0') ?? 0;

      if (success == 1) {
        final dynamic userData = data['data'];

        await store.write('username', phone);
        await store.write('isLoggedIn', true);

        if (userData is Map<String, dynamic>) {
          await store.write('user_id', userData['id']?.toString() ?? '');

          await store.write(
            'firstname',
            userData['firstname']?.toString() ?? '',
          );

          await store.write('lastname', userData['lastname']?.toString() ?? '');

          await store.write('email', userData['email']?.toString() ?? '');

          await store.write(
            'phone',
            userData['phone_num']?.toString() ?? phone,
          );
        }

        Get.snackbar(
          'Success',
          data['message']?.toString() ?? 'Login successful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        await Future.delayed(const Duration(milliseconds: 500));

        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'Login failed',
          data['message']?.toString() ?? 'Incorrect phone number or password.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on FormatException catch (error) {
      debugPrint('JSON error: $error');

      Get.snackbar(
        'Response error',
        'The server did not return valid JSON.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('Login error: $error');

      Get.snackbar(
        'Connection error',
        'Could not connect to the login server.\n$error',
        snackPosition: SnackPosition.BOTTOM,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Management Login'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              Image.asset(
                'assets/logo.png',
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.apartment, size: 120);
                },
              ),

              const SizedBox(height: 30),

              const Text(
                'Phone Number',
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  hintText: '0712345678',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Password',
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: passwordController,
                obscureText: !showPassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!isLoading) {
                    loginUser();
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  hintText: 'Enter password',
                  border: const OutlineInputBorder(),
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
              ),

              const SizedBox(height: 25),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
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
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Get.toNamed('/register');
                      },
                      child: Text(
                        'Not Registered? Sign Up',
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                  ),

                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password? Reset',
                        textAlign: TextAlign.right,
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
