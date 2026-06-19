import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
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

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
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

class CSBouiraApp extends StatelessWidget {
  const CSBouiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CS Bouira',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
