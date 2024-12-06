import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'src/screens/login.dart';
import 'src/screens/map.dart';
import 'src/screens/signup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/bottom_menu.dart';

void main() {
  runApp(
    // Riverpodでデータを受け渡しできる状態にする
    ProviderScope(child: ShopMapApp()),
  );
}

// GoRouterの設定
GoRouter router() {
  return GoRouter(
    // 最初のページ
    initialLocation: '/map',
    routes: [
      StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return AppNavigationBar(navigationShell: navigationShell);
          },
          branches: []),
      GoRoute(
        path: '/map',
        builder: (context, state) => MapPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(),
        routes: [
          // 新規登録ページのネスト
          GoRoute(
            path: 'signup',
            builder: (context, state) => SignUpPage(),
          ),
        ],
      ),
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
