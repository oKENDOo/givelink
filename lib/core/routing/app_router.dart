import 'package:go_router/go_router.dart';
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

final appRouter = GoRouter(
  initialLocation: '/', // เริ่มต้นที่หน้า Splash Screen
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // 3. เพิ่มเส้นทางไปหน้า Register
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
  GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  GoRoute(
      path: '/map',
      builder: (context, state) => const MapScreen(),
    ),  
    GoRoute(
      path: '/user',
      builder: (context, state) => const UserScreen(), 
    ),
        GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(), 
    ),
    GoRoute(
      path: '/donation_start',
      builder: (context, state) => const DonationStartScreen(), 
    ),
    GoRoute(
      path: '/donation_selection',
      builder: (context, state) => const DonationSelectionScreen(),
    ),
    GoRoute(
      path: '/donation_foundation',
      builder: (context, state) {
        // 🌟 รับข้อมูลที่ส่งมาจากหน้า Selection ผ่านตัวแปร extra
        final data = state.extra as Map<String, dynamic>? ?? {};
        return DonationFoundationScreen(
          selectedCategories: data['categories'] ?? [],
          othersText: data['others'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/donation_foundation_detail',
      builder: (context, state) {
        // 🌟 รับข้อมูล Mock Data ที่ส่งมาจากหน้าก่อนหน้า
        final data = state.extra as Map<String, dynamic>? ?? {};
        return DonationFoundationDetailScreen(foundationData: data);
      },
    ),
    GoRoute(
      path: '/donation_date',
      builder: (context, state) {
        // รับข้อมูลที่ส่งมาจากหน้า Detail
        final data = state.extra as Map<String, dynamic>? ?? {};
        return DonationDateScreen(
          foundationName: data['foundationName'] ?? 'ชื่อมูลนิธิ',
          selectedCategories: data['selectedCategories'] ?? [],
          othersText: data['othersText'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/donation_image',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return DonationImageScreen(
          foundationName: data['foundationName'] ?? '',
          selectedCategories: data['selectedCategories'] ?? [],
          othersText: data['othersText'] ?? '',
          selectedDate: data['selectedDate'] as DateTime?, // รับวันที่มาด้วย
        );
      },
    ),
    GoRoute(
      path: '/donation_summary',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return DonationSummaryScreen(
          foundationName: data['foundationName'] ?? '',
          selectedCategories: data['selectedCategories'] ?? [],
          othersText: data['othersText'] ?? '',
          selectedDate: data['selectedDate'] as DateTime?,
          selectedImages: data['selectedImages'] ?? [], // รับไฟล์รูปภาพมาด้วย
        );
      },
    ),
    GoRoute(
      path: '/donation_success',
      builder: (context, state) => const DonationSuccessScreen(),
    ),
  ],
);

//kendokendo14271@gmail.com
//ict555