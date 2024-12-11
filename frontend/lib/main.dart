import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'src/screens/login.dart';
import 'src/screens/map.dart';
import 'src/screens/signup.dart';
import 'src/screens/account.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/bottom_menu.dart';

void main() {
  runApp(
    // Riverpodでデータを受け渡しできる状態にする
    ProviderScope(child: ShopMapApp()),
  );
}

// それぞれどのルートがどのNavigatorに所属しているかを区別するためにGlobalKeyを生成し、各ルートおよびブランチに所属するNavigatorのGlobalKeyを紐づける
final rootNavigatorKey = GlobalKey<NavigatorState>();
final mapNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'map');
final loginNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'login');

// GoRouterの設定
GoRouter router() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    // 最初のページ
    initialLocation: '/map',
    routes: [
      // 複数のNavigatorとその状態保持を行うルート
      StatefulShellRoute.indexedStack(
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state, navigationShell) {
            // ボトムナビゲーションバーの実装がbuilder内で生成される
            return AppNavigationBar(navigationShell: navigationShell);
          },
          branches: [
            // mapブランチ
            StatefulShellBranch(
              navigatorKey: mapNavigatorKey,
              routes: [
                GoRoute(
                  path: '/map',
                  builder: (context, state) => MapPage(),
                ),
              ],
            ),
            // loginブランチ
            StatefulShellBranch(
              navigatorKey: loginNavigatorKey,
              routes: [
                GoRoute(
                  path: '/login',
                  builder: (context, state) => LoginPage(),
                  routes: [
                    // 新規登録ページのネスト
                    GoRoute(
                      path: 'signup',
                      builder: (context, state) => SignUpPage(),
                    ),
                    // accountページのネスト
                    GoRoute(
                      path: 'account',
                      builder: (context, state) => AccountPage(),
                    ),
                  ],
                ),
              ],
            ),
          ]),
    ],
  );
}

class ShopMapApp extends StatelessWidget {
  const ShopMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      // アプリ名
      title: 'マップアプリ',
      theme: ThemeData(
        // テーマカラー
        primarySwatch: Colors.amber,
      ),
      // GoRouterのインスタンスを渡す
      routerConfig: router(),
    );
  }
}
