import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/provider.dart';

// マップ表示
class MapPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在位置を取得
    final currentLocationAsync = ref.watch(currentLocationProvider);

    // 現在のマーカーセットを取得
    final markers = ref.watch(markersProvider);

    // ボトムモーダルの状態を取得
    final bottomModalActive = ref.watch(bottomModalActiveProvider);

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
            // モーダルの表示時にはマップ操作を無効
            scrollGesturesEnabled: !bottomModalActive,
            zoomControlsEnabled: !bottomModalActive,
            rotateGesturesEnabled: !bottomModalActive,
            tiltGesturesEnabled: !bottomModalActive,
            onTap: (LatLng position) {
              // ボトムモーダルの状態を確認(trueの場合はマップのタップを無効に)
              if (bottomModalActive) {
                return;
              }

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

              // モーダル表示時にボトムモーダルをアクティブにする
              ref.read(bottomModalActiveProvider.notifier).state = true;

              // マーカーを追加後にモーダルを表示
              showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return Consumer(
                      builder: (context, ref, child) {
                        // フォームにて、チップの選択状態を取得
                        final filterChip01 = ref.watch(filterChipProvider01);
                        final filterChip02 = ref.watch(filterChipProvider02);

                        // フォームにて、両替機の選択状態を取得
                        final exchangeMachine =
                            ref.watch(exchangeMachineProvider);

                        // 入力の値を受け取る(必要？？)
                        final shopName = ref.watch(shopNameProvider);
                        final genre = ref.watch(genreProvider);
                        final unit = ref.watch(unitProvider);

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(child: Text("ガチャガチャ場所の登録")),
                              SizedBox(height: 8),
                              TextField(
                                  decoration: InputDecoration(
                                    hintText: "店名を入力してください",
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (String value) {
                                    // ユーザーの入力をProviderに保存
                                    ref.watch(shopNameProvider.notifier).state =
                                        value;
                                  }),
                              SizedBox(height: 8),
                              Text("何のガチャが多いか？"),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(
                                    choices01.length,
                                    (index) {
                                      return FilterChip(
                                        showCheckmark: true,
                                        label: Text(choices01[index]),
                                        onSelected: (value) {
                                          // Providerを使って状態を更新
                                          ref
                                              .watch(
                                                  filterChipProvider01.notifier)
                                              .toggleSelection(index);
                                        },
                                        selected: filterChip01[index],
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text("ガチャ台数"),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(
                                    choices02.length,
                                    (index) {
                                      return FilterChip(
                                        showCheckmark: true,
                                        label: Text(choices02[index]),
                                        onSelected: (value) {
                                          // Providerを使って状態を更新
                                          ref
                                              .watch(
                                                  filterChipProvider02.notifier)
                                              .toggleSelection(index);
                                        },
                                        selected: filterChip02[index],
                                      );
                                    },
                                  ),
                                ),
                              ),
                              CheckboxListTile(
                                title: Text("両替機がある"),
                                value: exchangeMachine,
                                onChanged: (bool? value) {
                                  if (value != null) {
                                    ref
                                        .watch(exchangeMachineProvider.notifier)
                                        .state = value;
                                    // デバッグコンソールにメッセージを表示
                                    print("両替機の状態が変更されました: $value");
                                  }
                                },
                                activeColor: Colors.green,
                                checkColor: Colors.white,
                              ),
                              SizedBox(height: 8),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      final response = await http.post(
                                        Uri.parse(
                                            'http://localhost:8080/registeringlocation'),
                                        // Uri.parse('http://172.16.0.57:8080/registeringlocation'),
                                        headers: {
                                          'Content-Type': 'application/json'
                                        },
                                        body: json.encode({
                                          'shop_name': shopName,
                                          'genre': genre,
                                          'unit': unit,
                                          'exchange_machine': exchangeMachine,
                                        }),
                                      );
                                    } catch (e) {
                                      Text("これはエラーですわ");
                                    }
                                  },
                                  child: Text("場所を登録する"),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      // width: MediaQuery.of(context).size.width,
                      // padding: const EdgeInsets.all(16.0),
                      // child: Column(
                      //   mainAxisSize: MainAxisSize.min,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     // Text(
                      //     //   "緯度： ${position.latitude}",
                      //     // ),
                      //     // Text(
                      //     //   "経度： ${position.longitude}",
                      //     // ),
                      //     Center(child: Text("ガチャガチャ場所の登録")),
                      //     SizedBox(height: 8),
                      //     TextField(
                      //         decoration: InputDecoration(
                      //           hintText: "店名を入力してください",
                      //           border: OutlineInputBorder(),
                      //         ),
                      //         onChanged: (String value) {
                      //           // ユーザーの入力をProviderに保存
                      //           ref.watch(shopNameProvider.notifier).state =
                      //               value;
                      //         }),
                      //     SizedBox(height: 8),
                      //     Text("何のガチャが多いか？"),
                      //     Container(
                      //       width: MediaQuery.of(context).size.width,
                      //       padding: const EdgeInsets.all(8.0),
                      //       child: Wrap(
                      //         spacing: 8,
                      //         runSpacing: 8,
                      //         children: List.generate(
                      //           choices01.length,
                      //           (index) {
                      //             return FilterChip(
                      //               showCheckmark: true,
                      //               label: Text(choices01[index]),
                      //               onSelected: (value) {
                      //                 // Providerを使って状態を更新
                      //                 ref
                      //                     .watch(filterChipProvider01.notifier)
                      //                     .toggleSelection(index);
                      //               },
                      //               selected: filterChip01[index],
                      //             );
                      //           },
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(height: 8),
                      //     Text("ガチャ台数"),
                      //     Container(
                      //       width: MediaQuery.of(context).size.width,
                      //       padding: const EdgeInsets.all(8.0),
                      //       child: Wrap(
                      //         spacing: 8,
                      //         runSpacing: 8,
                      //         children: List.generate(
                      //           choices02.length,
                      //           (index) {
                      //             return FilterChip(
                      //               showCheckmark: true,
                      //               label: Text(choices02[index]),
                      //               onSelected: (value) {
                      //                 Text("hoge");
                      //               },
                      //               selected: filterChip02[index],
                      //             );
                      //           },
                      //         ),
                      //       ),
                      //     ),
                      //     CheckboxListTile(
                      //       title: Text("両替機がある"),
                      //       value: exchangeMachine,
                      //       onChanged: (bool? value) {
                      //         if (value != null) {
                      //           ref
                      //               .watch(exchangeMachineProvider.notifier)
                      //               .state = value;
                      //           // デバッグコンソールにメッセージを表示
                      //           print("両替機の状態が変更されました: $value");
                      //         }
                      //       },
                      //       activeColor: Colors.green,
                      //       checkColor: Colors.white,
                      //     ),
                      //     SizedBox(height: 8),
                      //     Center(
                      //       child: ElevatedButton(
                      //         onPressed: () async {
                      //           try {
                      //             final response = await http.post(
                      //               Uri.parse(
                      //                   'http://localhost:8080/registeringlocation'),
                      //               // Uri.parse('http://172.16.0.57:8080/registeringlocation'),
                      //               headers: {
                      //                 'Content-Type': 'application/json'
                      //               },
                      //               body: json.encode({
                      //                 'shop_name': shopName,
                      //                 'genre': genre,
                      //                 'unit': unit,
                      //                 'exchange_machine': exchangeMachine,
                      //               }),
                      //             );
                      //           } catch (e) {
                      //             Text("これはエラーですわ");
                      //           }
                      //         },
                      //         child: Text("場所を登録する"),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    );
                  }).whenComplete(() {
                ref.watch(bottomModalActiveProvider.notifier).state = false;
                // フォームの入力された値を削除
                ref.watch(shopNameProvider.notifier).state = "";
                ref.watch(exchangeMachineProvider.notifier).state = false;

                // FilterChipの選択状態をリセット
                ref.read(filterChipProvider01.notifier).reset();
                ref.read(filterChipProvider02.notifier).reset();
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
