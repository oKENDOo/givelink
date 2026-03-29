import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import หน้าจอต่างๆ
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart'; 
import '../../features/map/screens/map_screen.dart';
import '../../features/user/screens/user_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/donation/screens/donation_start_screen.dart';
import '../../features/donation/screens/donation_selection_screen.dart';
import '../../features/donation/screens/donation_foundation_screen.dart';
import '../../features/donation/screens/donation_foundation_detail_screen.dart';
import '../../features/donation/screens/donation_date_screen.dart';
import '../../features/donation/screens/donation_image_screen.dart';
import '../../features/donation/screens/donation_summary_screen.dart';
import '../../features/donation/screens/donation_success_screen.dart';
import '../../features/user/screens/user_edit_info_screen.dart';

// Import หน้ากรอบหลัก (ที่มีแถบสีฟ้า)
import '../../features/main_layout_screen.dart';

// ตั้งค่า Router ให้รู้จักการซ้อนหน้า
final appRouter = GoRouter(
  initialLocation: '/', 
  routes: [
    // --- กลุ่มหน้าที่ "ไม่มี" แถบเมนูด้านล่าง (เต็มจอปกติ) ---
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),

    // --- 🌟 กลุ่มหน้าที่ "มี" แถบเมนูด้านล่าง (ถูกครอบด้วย Shell) ---
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayoutScreen(navigationShell: navigationShell);
      },
      branches: [
        // 📍 Tab 0: หน้าหลัก
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          ],
        ),
        // 📍 Tab 1: แผนที่
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
          ],
        ),
        // 📍 Tab 2: หมวดบริจาค
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/donation_start', builder: (context, state) => const DonationStartScreen()),
            GoRoute(path: '/donation_selection', builder: (context, state) => const DonationSelectionScreen()),
            GoRoute(
              path: '/donation_foundation',
              builder: (context, state) {
                final data = state.extra as Map<String, dynamic>? ?? {};
                return DonationFoundationScreen(
                  // 🌟 บังคับแปลงเป็น List<String> เสมอ ป้องกันการแครช
                  selectedCategories: (data['categories'] as List<dynamic>?)?.cast<String>() ?? <String>[],
                  othersText: (data['others'] as String?) ?? '',
                );
              },
            ),
            GoRoute(
              path: '/donation_foundation_detail',
              builder: (context, state) {
                final data = state.extra as Map<String, dynamic>? ?? {};
                return DonationFoundationDetailScreen(foundationData: data);
              },
            ),
            GoRoute(
              path: '/donation_date',
              builder: (context, state) {
                final data = state.extra as Map<String, dynamic>? ?? {};
                return DonationDateScreen(
                  // 🌟 บังคับแปลง Type ให้ปลอดภัยทั้งหมด
                  foundationName: (data['foundationName'] as String?) ?? 'ชื่อมูลนิธิ',
                  selectedCategories: (data['selectedCategories'] as List<dynamic>?)?.cast<String>() ?? <String>[],
                  othersText: (data['othersText'] as String?) ?? '',
                );
              },
            ),
            GoRoute(
              path: '/donation_image',
              builder: (context, state) {
                final data = state.extra as Map<String, dynamic>? ?? {};
                return DonationImageScreen(
                  foundationName: (data['foundationName'] as String?) ?? '',
                  selectedCategories: (data['selectedCategories'] as List<dynamic>?)?.cast<String>() ?? <String>[],
                  othersText: (data['othersText'] as String?) ?? '',
                  selectedDate: data['selectedDate'] as DateTime?, 
                );
              },
            ),
            GoRoute(
              path: '/donation_summary',
              builder: (context, state) {
                final data = state.extra as Map<String, dynamic>? ?? {};
                return DonationSummaryScreen(
                  foundationName: (data['foundationName'] as String?) ?? '',
                  selectedCategories: (data['selectedCategories'] as List<dynamic>?)?.cast<String>() ?? <String>[],
                  othersText: (data['othersText'] as String?) ?? '',
                  selectedDate: data['selectedDate'] as DateTime?,
                  selectedImages: (data['selectedImages'] as List<dynamic>?) ?? [], 
                );
              },
            ),
            GoRoute(path: '/donation_success', builder: (context, state) => const DonationSuccessScreen()),
          ],
        ),
        // 📍 Tab 3: ประวัติ
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/history', builder: (context, state) => const HistoryScreen()),
          ],
        ),
        // 📍 Tab 4: ผู้ใช้
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/user', builder: (context, state) => const UserScreen()),
            GoRoute(path: '/user_edit', builder: (context, state) => const UserEditInfoScreen()),
          ],
        ),
      ],
    ),
  ],
);