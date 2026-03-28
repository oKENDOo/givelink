import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/user/screens/user_screen.dart';
import '../../features/history/screens/history_screen.dart';

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
  ],
);

//kendokendo14271@gmail.com
//123456