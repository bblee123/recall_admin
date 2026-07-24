import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';

/// 侧边导航项定义（对照 Vue 项目 default-layout 菜单 + 路由 meta.title）。
class _NavItem {
  const _NavItem(this.path, this.label, this.icon, {this.admin = false});
  final String path;
  final String label;
  final IconData icon;
  final bool admin;
}

const List<_NavItem> _navItems = <_NavItem>[
  _NavItem('/', '文字', Icons.translate),
  _NavItem('/variant', '汉字释义', Icons.menu_book),
  _NavItem('/words', '词汇', Icons.abc),
  _NavItem('/recorder-test', '录音测试', Icons.mic),
  _NavItem('/admin/categories', '书籍分类', Icons.category, admin: true),
  _NavItem('/admin/books', '书籍管理', Icons.library_books, admin: true),
  _NavItem('/admin/recommendation-base', '默认推荐', Icons.recommend,
      admin: true),
  _NavItem('/admin/recommendation-event', '节日推荐', Icons.event, admin: true),
];

/// 桌面外壳：左侧 NavigationRail + 右侧内容区。
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    // 选中最长匹配前缀的项。
    var index = 0;
    var bestLen = -1;
    for (var i = 0; i < _navItems.length; i++) {
      final path = _navItems[i].path;
      final matched = path == '/'
          ? location == '/'
          : location == path || location.startsWith('$path/');
      if (matched && path.length > bestLen) {
        bestLen = path.length;
        index = i;
      }
    }
    return index;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedIndex(context);
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selected,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (i) => context.go(_navItems[i].path),
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Icon(Icons.brush, size: 28),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return IconButton(
                        tooltip: state.loggedIn ? '退出登录' : '管理端登录',
                        icon: Icon(
                          state.loggedIn ? Icons.logout : Icons.login,
                        ),
                        onPressed: () {
                          final cubit = context.read<AuthCubit>();
                          if (state.loggedIn) {
                            cubit.logout();
                          } else {
                            cubit.openDialog(
                              GoRouterState.of(context).uri.path,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            destinations: _navItems
                .map(
                  (e) => NavigationRailDestination(
                    icon: Icon(e.icon),
                    label: Text(e.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
