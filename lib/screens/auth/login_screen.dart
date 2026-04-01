import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;
  
  final AuthController _authController = Get.find();

  void _login() {
    final email = _email.text.trim();
    final password = _password.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    _authController.login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient & Shapes
          Positioned(
            top: -100,
            left: -100,
            child: CircleAvatar(radius: 150, backgroundColor: AppColors.primary.withOpacity(0.1)),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: CircleAvatar(radius: 100, backgroundColor: AppColors.primary.withOpacity(0.05)),
          ),
          
          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  // Logo Section
                  Hero(
                    tag: 'logo',
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      child: const Icon(Icons.rocket_launch_rounded, size: 60, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'GURU-PAY',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white),
                  ),
                  const Text('Premium Gateway for Financial Freedom', style: TextStyle(color: AppColors.textBody, fontSize: 13)),
                  const SizedBox(height: 60),

                  // Glass Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _email,
                              label: 'Email address',
                              icon: Icons.alternate_email,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _password,
                              label: 'Password',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              obscure: _obscurePassword,
                              onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            const SizedBox(height: 40),
                            Obx(() => SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _authController.isLoading.value ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 5,
                                  shadowColor: AppColors.primary.withOpacity(0.4),
                                ),
                                child: _authController.isLoading.value 
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                                  : const Text('Login Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            )),
                            const SizedBox(height: 20),
                            // Google Login Button
                            Obx(() => SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: OutlinedButton.icon(
                                onPressed: _authController.isLoading.value ? null : () => _authController.googleSignIn(),
                                icon: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_\"G\"_logo.svg/1200px-Google_\"G\"_logo.svg.png', height: 22),
                                label: const Text('Continue with Google', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  backgroundColor: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  TextButton(
                    onPressed: () => Get.to(() => const RegisterScreen()),
                    child: RichText(
                      text: const TextSpan(
                        text: "New to GURU-PAY? ",
                        style: TextStyle(color: AppColors.textBody, fontSize: 14),
                        children: [
                          TextSpan(text: "Register Now", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: label.toLowerCase().contains('email') ? TextInputType.emailAddress : TextInputType.text,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white24, size: 20),
              suffixIcon: isPassword ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white24, size: 20),
                onPressed: onToggle,
              ) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(18),
            ),
          ),
        ),
      ],
    );
  }
}
