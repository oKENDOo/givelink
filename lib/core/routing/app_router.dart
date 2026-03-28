import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';

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
      builder: (context, state) => const HomeScreen(), // 🌟 เพิ่มบรรทัดนี้
    ),
    
  ],
);

//kendokendo14271@gmail.com
//123456