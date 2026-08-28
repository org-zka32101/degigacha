import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/capture_screen.dart';
import '../presentation/screens/login_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // TODO: Implement auth state check
      // final isLoggedIn = ref.read(authNotifierProvider).uid != null;
      // if (!isLoggedIn && state.location != '/login') {
      //   return '/login';
      // }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'capture',
            builder: (context, state) => const CaptureScreen(),
          ),
          // TODO: Add more routes
          // GoRoute(
          //   path: 'collection',
          //   builder: (context, state) => const CollectionScreen(),
          // ),
          // GoRoute(
          //   path: 'trade',
          //   builder: (context, state) => const TradeScreen(),
          // ),
        ],
      ),
    ],
  );
});
