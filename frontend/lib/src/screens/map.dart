import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider.dart';

// マップ表示
class MapPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在位置を取得
    final currentLocationAsync = ref.watch(currentLocationProvider);

    // 現在のマーカーセットを取得
    final markers = ref.watch(markersProvider);

    return Scaffold(
      body: currentLocationAsync.when(
        data: (currentLocation) {
          // マップの初期位置を現在位置に更新(ビルドが完了した後にプロバイダーの状態を更新)
          Future(() {
            ref.read(mapCenterProvider.notifier).state = currentLocation;
          });

          return GoogleMap(
            // マップ生成時にコントローラーをプロバイダーに設定
            onMapCreated: (GoogleMapController controller) {
              // マップ生成時にcontrollerに書き込み
              ref.read(googleMapControllerProvider.notifier).state = controller;
            },
            initialCameraPosition: CameraPosition(
              target: currentLocation,
              zoom: 11.0,
            ),
            myLocationEnabled: true, // 現在位置をマップ上に表示
            markers: markers,
            onTap: (LatLng position) {
              // マーカーが既に存在しているか確認
              if (markers.any(
                  (marker) => _isSameLocation(marker.position, position))) {
                // 既に存在している場合は追加しない
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("既にこの位置にマーカーがあります"),
                  ),
                );
                return;
              }

              // マーカーを追加
              ref.read(markersProvider.notifier).update((currentMarkers) {
                final newMarker = Marker(
                  markerId: MarkerId(position.toString()),
                  position: position,
                  infoWindow: InfoWindow(
                    title: "New Marker",
                    snippet:
                        "Lat: ${position.latitude}, Lng: ${position.longitude}",
                  ),
                );
                return {...currentMarkers, newMarker};
              });
            },
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()), // 読み込み中
        error: (err, stack) => Center(child: Text("エラー: $err")), // エラー時
      ),
    );
  }
}

// 緯度・軽度が近似しているか確認するヘルパー関数
bool _isSameLocation(LatLng position1, LatLng position2,
    {double tolerance = 0.0001}) {
  return (position1.latitude - position2.latitude).abs() < tolerance &&
      (position1.longitude - position2.longitude).abs() < tolerance;
}
