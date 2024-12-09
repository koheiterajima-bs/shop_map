import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider.dart';

// マップ表示
class MapPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // マップの初期位置の値を読み込む
    LatLng mapCenter = ref.watch(mapCenterProvider);

    return Scaffold(
      body: GoogleMap(
        // マップ生成時にコントローラーをプロバイダーに設定
        onMapCreated: (GoogleMapController controller) {
          // マップ生成時にcontrollerに書き込み
          ref.read(googleMapControllerProvider.notifier).state = controller;
        },
        initialCameraPosition: CameraPosition(
          target: mapCenter,
          zoom: 11.0,
        ),
      ),
    );
  }
}
