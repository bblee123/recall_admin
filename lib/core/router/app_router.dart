import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin_books/books_page.dart';
import '../../features/admin_categories/categories_page.dart';
import '../../features/admin_recommendation/base_recommendation_page.dart';
import '../../features/admin_recommendation/event_recommendation_page.dart';
import '../../features/home/home_page.dart';
import '../../features/not_found/not_found_page.dart';
import '../../features/recorder/recorder_test_page.dart';
import '../../features/shell/app_shell.dart';
import '../../features/variant/variant_page.dart';
import '../../features/words/words_page.dart';
import '../network/session_controller.dart';
import '../storage/token_storage.dart';

/// 构建应用路由（对照 Vue 项目 router/index.ts + admin-route.ts）。
GoRouter buildRouter({
  required TokenStorage tokenStorage,
  required SessionController session,
}) {
  Page<void> noTransition(Widget child) =>
      NoTransitionPage<void>(child: child);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.uri.path;
      final needsAdmin = path.startsWith('/admin');
      if (needsAdmin && !tokenStorage.hasToken) {
        // 无 token：请求登录并回到首页（对照 beforeEach 的 openLoginDialog + 留在原页）。
        WidgetsBinding.instance.addPostFrameCallback((_) {
          session.requireLogin(path);
        });
        return '/';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (c, s) => noTransition(const HomePage()),
          ),
          GoRoute(
            path: '/variant',
            pageBuilder: (c, s) => noTransition(const VariantPage()),
          ),
          GoRoute(
            path: '/words',
            pageBuilder: (c, s) => noTransition(const WordsPage()),
          ),
          GoRoute(
            path: '/recorder-test',
            pageBuilder: (c, s) => noTransition(const RecorderTestPage()),
          ),
          GoRoute(
            path: '/admin/categories',
            pageBuilder: (c, s) => noTransition(const CategoriesPage()),
          ),
          GoRoute(
            path: '/admin/books',
            pageBuilder: (c, s) => noTransition(
              BooksPage(categoryId: s.uri.queryParameters['categoryId']),
            ),
          ),
          GoRoute(
            path: '/admin/recommendation-base',
            pageBuilder: (c, s) => noTransition(const BaseRecommendationPage()),
          ),
          GoRoute(
            path: '/admin/recommendation-event',
            pageBuilder: (c, s) =>
                noTransition(const EventRecommendationPage()),
          ),
        ],
      ),
    ],
    errorPageBuilder: (c, s) => noTransition(const NotFoundPage()),
  );
}
