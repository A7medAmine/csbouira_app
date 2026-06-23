import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/auth_providers.dart';
import 'data/providers/favorites_providers.dart';
import 'features/about/about_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/browse/file_screen.dart';
import 'features/browse/folder_screen.dart';
import 'features/browse/module_screen.dart';
import 'features/browse/semester_screen.dart';
import 'features/downloads/downloads_screen.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/home/home_screen.dart';
import 'features/preview/preview_screen.dart';
import 'features/scan/qr_scanner_screen.dart';
import 'features/profile/my_uploads_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/search/search_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/upload/upload_screen.dart';
import 'shared/widgets/app_bottom_nav.dart';

class _AuthRefreshNotifier extends ChangeNotifier {
  void trigger() => notifyListeners();
}

/// Global full-screen toggle used by PreviewScreen to hide the shell's
/// bottom navigation bar without affecting other screens.
final fullScreenNotifier = ValueNotifier<bool>(false);

final _authRefreshNotifier = _AuthRefreshNotifier();

CustomTransitionPage<void> _buildTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

final _routerProvider = Provider<GoRouter>((ref) {
  ref.listen(authStateProvider, (_, __) {
    _authRefreshNotifier.trigger();
    // Refresh favorites and profile data when auth state changes (login/logout)
    ref.invalidate(favoritesListProvider);
  });

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
        pageBuilder: (_, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _ShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                pageBuilder: (_, state) => _buildTransitionPage(
                  key: state.pageKey,
                  child: const HomeScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'year/:year',
                    name: 'semester',
                    pageBuilder: (_, state) => _buildTransitionPage(
                      key: state.pageKey,
                      child: SemesterScreen(
                        year: state.pathParameters['year']!,
                      ),
                    ),
                    routes: [
                      GoRoute(
                        path: 'books',
                        name: 'books',
                        pageBuilder: (_, state) => _buildTransitionPage(
                          key: state.pageKey,
                          child: FileScreen(
                            year: state.pathParameters['year']!,
                            semester: '',
                            module: '',
                            folder: 'Books & Exercices',
                            subpath: state.uri.queryParameters['sub'] ?? '',
                          ),
                        ),
                      ),
                      GoRoute(
                        path: 'semester/:semester',
                        name: 'module',
                        pageBuilder: (_, state) => _buildTransitionPage(
                          key: state.pageKey,
                          child: ModuleScreen(
                            year: state.pathParameters['year']!,
                            semester: state.pathParameters['semester']!,
                          ),
                        ),
                        routes: [
                          GoRoute(
                            path: 'module/:module',
                            name: 'folder',
                            pageBuilder: (_, state) => _buildTransitionPage(
                              key: state.pageKey,
                              child: FolderScreen(
                                year: state.pathParameters['year']!,
                                semester: state.pathParameters['semester']!,
                                module: state.pathParameters['module']!,
                              ),
                            ),
                            routes: [
                              GoRoute(
                                path: 'folder/:folder',
                                name: 'file',
                                pageBuilder: (_, state) => _buildTransitionPage(
                                  key: state.pageKey,
                                  child: FileScreen(
                                    year: state.pathParameters['year']!,
                                    semester: state.pathParameters['semester']!,
                                    module: state.pathParameters['module']!,
                                    folder: state.pathParameters['folder']!,
                                    subpath: state.uri.queryParameters['sub'] ?? '',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'preview',
                    name: 'preview',
                    pageBuilder: (_, state) => _buildTransitionPage(
                      key: state.pageKey,
                      child: const PreviewScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'scan',
                    name: 'scan',
                    pageBuilder: (_, state) => _buildTransitionPage(
                      key: state.pageKey,
                      child: const QrScannerScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 1: Search
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                name: 'search',
                pageBuilder: (_, state) => _buildTransitionPage(
                  key: state.pageKey,
                  child: const SearchScreen(),
                ),
              ),
            ],
          ),
          // Branch 2: Favorites
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                name: 'favorites',
                pageBuilder: (_, state) => _buildTransitionPage(
                  key: state.pageKey,
                  child: const FavoritesScreen(),
                ),
              ),
            ],
          ),
          // Branch 3: Upload
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/upload',
                name: 'upload',
                pageBuilder: (_, state) => _buildTransitionPage(
                  key: state.pageKey,
                  child: const UploadScreen(),
                ),
              ),
            ],
          ),
          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                pageBuilder: (_, state) => _buildTransitionPage(
                  key: state.pageKey,
                  child: const ProfileScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'my-uploads',
                    name: 'myUploads',
                    pageBuilder: (_, state) => _buildTransitionPage(
                      key: state.pageKey,
                      child: const MyUploadsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'my-downloads',
                    name: 'myDownloads',
                    pageBuilder: (_, state) => _buildTransitionPage(
                      key: state.pageKey,
                      child: const DownloadsScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 5: Downloads
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/downloads',
                name: 'downloads',
                pageBuilder: (_, state) => _buildTransitionPage(
                  key: state.pageKey,
                  child: const DownloadsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (_, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        pageBuilder: (_, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        pageBuilder: (_, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const AboutScreen(),
        ),
      ),
    ],
  );
});

class _ShellScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const _ShellScaffold({required this.navigationShell});

  @override
  State<_ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<_ShellScaffold> {
  DateTime? _lastBackPress;

  bool _canPop() {
    final branch =
        widget.navigationShell.route.branches[widget.navigationShell.currentIndex];
    return branch.navigatorKey.currentState?.canPop() ?? false;
  }

  void _onPopInvokedWithResult(bool didPop, _) {
    if (didPop) return;

    // If a text field currently has focus, dismiss the keyboard only.
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus != null && primaryFocus.context?.widget is EditableText) {
      primaryFocus.unfocus();
      return;
    }
    // Fallback for any open keyboard without focus.
    if (MediaQuery.of(context).viewInsets.bottom > 0) {
      FocusScope.of(context).unfocus();
      return;
    }

    if (_canPop()) {
      final branch = widget.navigationShell
          .route.branches[widget.navigationShell.currentIndex];
      branch.navigatorKey.currentState?.pop();
      return;
    }
    if (widget.navigationShell.currentIndex != 0) {
      widget.navigationShell.goBranch(0, initialLocation: true);
      return;
    }
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Press back again to exit')),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: fullScreenNotifier,
      builder: (context, isFullScreen, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: _onPopInvokedWithResult,
          child: Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: KeyedSubtree(
                key: ValueKey<int>(widget.navigationShell.currentIndex),
                child: widget.navigationShell,
              ),
            ),
            bottomNavigationBar: isFullScreen
                ? null
                : AppBottomNav(
                    navigationShell: widget.navigationShell,
                  ),
          ),
        );
      },
    );
  }
}

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
        // Lock text scaling to 1.0 to ignore system font size settings.
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
      );
  }
}
