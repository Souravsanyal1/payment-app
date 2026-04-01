import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'controllers/auth_controller.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/dashboard/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize AuthController globally
  Get.put(AuthController());
  
  runApp(const GuruPayApp());
}

class GuruPayApp extends StatelessWidget {
  const GuruPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GURU-PAY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButtonThemeData().style?.copyWith(
            backgroundColor: WidgetStateProperty.all(AppColors.primary),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/dashboard', page: () => const DashboardScreen()),
        GetPage(name: '/admin', page: () => const AdminDashboardScreen()),
      ],
    );
  }
}
