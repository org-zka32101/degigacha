import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/capture_screen.dart';
import '../presentation/screens/login_screen.dart';

import '../presentation/riverpod/auth_notifier.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/' : '/login',
    redirect: (context, state) {
      // ユーザーがログインしていない場合
      if (!authState.isAuthenticated && state.location != '/login') {
        return '/login';
      }

      // ユーザーがログイン済みでログイン画面にアクセスしている場合
      if (authState.isAuthenticated && state.location == '/login') {
        return '/';
      }

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
