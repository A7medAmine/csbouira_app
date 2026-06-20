import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/auth_providers.dart';
import 'features/about/about_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/browse/file_screen.dart';
import 'features/browse/folder_screen.dart';
import 'features/browse/module_screen.dart';
import 'features/browse/semester_screen.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/home/home_screen.dart';
import 'features/preview/preview_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/search/search_screen.dart';
import 'features/upload/upload_screen.dart';

class _AuthRefreshNotifier extends ChangeNotifier {
  void trigger() => notifyListeners();
}

final _authRefreshNotifier = _AuthRefreshNotifier();

final _routerProvider = Provider<GoRouter>((ref) {
  ref.listen(authStateProvider, (_, __) => _authRefreshNotifier.trigger());

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _authRefreshNotifier,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final loggedIn = session?.user != null;
      final isLoginRoute = state.matchedLocation == '/login';
      final isSplashRoute = state.matchedLocation == '/splash';

      if (isSplashRoute) return null;
      if (loggedIn && isLoginRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/year/:year',
        name: 'semester',
        builder: (_, state) => SemesterScreen(
          year: state.pathParameters['year']!,
        ),
        routes: [
          GoRoute(
            path: 'books',
            name: 'books',
            builder: (_, state) => FileScreen(
              year: state.pathParameters['year']!,
              semester: '',
              module: '',
              folder: 'Books & Exercices',
              subpath: state.uri.queryParameters['sub'] ?? '',
            ),
          ),
          GoRoute(
            path: 'semester/:semester',
            name: 'module',
            builder: (_, state) => ModuleScreen(
              year: state.pathParameters['year']!,
              semester: state.pathParameters['semester']!,
            ),
            routes: [
              GoRoute(
                path: 'module/:module',
                name: 'folder',
                builder: (_, state) => FolderScreen(
                  year: state.pathParameters['year']!,
                  semester: state.pathParameters['semester']!,
                  module: state.pathParameters['module']!,
                ),
                routes: [
                  GoRoute(
                    path: 'folder/:folder',
                    name: 'file',
                    builder: (_, state) => FileScreen(
                      year: state.pathParameters['year']!,
                      semester: state.pathParameters['semester']!,
                      module: state.pathParameters['module']!,
                      folder: state.pathParameters['folder']!,
                      subpath: state.uri.queryParameters['sub'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (_, __) => const SearchScreen(),
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (_, __) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/upload',
        name: 'upload',
        builder: (_, __) => const UploadScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (_, __) => const AboutScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/preview',
        name: 'preview',
        builder: (_, state) => const PreviewScreen(),
      ),
    ],
  );
});

class CSBouiraApp extends ConsumerWidget {
  const CSBouiraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      title: 'CS Bouira',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
