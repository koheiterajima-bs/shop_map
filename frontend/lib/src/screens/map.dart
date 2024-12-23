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

    // ドロップダウンの選択肢(何系のガチャガチャが多いか)
    Map<String, String> dropDownMap01 = {
      "1": "キャラ",
      "2": "ミニチュア",
      "3": "マニアック"
    };

    // ドロップダウンの選択肢(何台程度あるか)
    Map<String, String> dropDownMap02 = {
      "1": "0〜10台",
      "2": "11〜50台",
      "3": "51〜100台",
      "4": "それ以上"
    };
    String? selectedValue; // 選択された値を保持する変数

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
              zoom: 18.0,
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

              // マーカーを追加後にモーダルを表示
              showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "緯度： ${position.latitude}",
                          ),
                          Text(
                            "経度： ${position.longitude}",
                          ),
                          TextField(
                            decoration: InputDecoration(
                              hintText: "店名を入力してください",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 8),
                          DropdownButton(
                              value: selectedValue, // 現在選択されている値
                              items: dropDownMap01.entries.map((entry) {
                                return DropdownMenuItem(
                                  value: entry.key, // Mapのキーを値として設定
                                  child:
                                      Text(entry.value), // Mapの値を表示するテキストとして設定
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                Text("ドロップダウンのメニュー");
                              }),
                          SizedBox(height: 8),
                          DropdownButton(
                              value: selectedValue, // 現在選択されている値
                              items: dropDownMap02.entries.map((entry) {
                                return DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                Text("ドロップダウンのメニュー");
                              }),
                          CheckboxListTile(
                            title: Text("両替機がある"),
                            value: false,
                            onChanged: (bool? value) {
                              Text("チェックが入りました");
                            },
                            activeColor: Colors.green,
                            checkColor: Colors.red,
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    );
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
