// ボトムナビゲーションの実装
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './screens/login.dart';
import './screens/map.dart';
import './providers/provider.dart';
import '../main.dart';

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.map), label: 'map'),
            NavigationDestination(icon: Icon(Icons.person), label: 'login'),
          ],
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          }),
    );
  }
}

// 以下、没
// class BottomMenu extends ConsumerWidget {
//   const BottomMenu({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Providerの値を監視
//     final bottomMenuCounter = ref.watch(counterProvider);
//     // 各画面のリスト(表示する画面をリストとして格納)
//     const screens = [LoginPage(), MapPage()];

//     return Scaffold(
//       body: screens[bottomMenuCounter],
//       bottomNavigationBar: NavigationBar(
//         onDestinationSelected: (int index) {
//           // Providerの値を更新
//           ref.read(counterProvider.notifier).state++;
//         },
//         indicatorColor: Colors.amber,
//         selectedIndex: bottomMenuCounter,
//         destinations: const <Widget>[
//           NavigationDestination(
//             selectedIcon: Icon(Icons.map),
//             icon: Icon(Icons.map),
//             label: 'Map',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.settings),
//             label: 'Settings',
//           ),
//         ],
//       ),
//     );
//   }
// }

