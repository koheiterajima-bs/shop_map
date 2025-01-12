import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shop_map/main.dart';
import 'dart:convert';
import '../providers/provider.dart';
import 'package:logger/logger.dart';

// Loggerインスタンスを作成
final logger = Logger();

// マップ表示
class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在位置を取得
    final currentLocationAsync = ref.watch(currentLocationProvider);

    // 現在のマーカーセットを取得
    // final markers = ref.watch(markersProvider);

    // ボトムモーダルの状態を取得
    final bottomModalActive = ref.watch(bottomModalActiveProvider);

    // バックエンドから取得してきたマーカー情報をポーリングにて取得
    final markerStream = ref.watch(markerStreamProvider);

    // セッションの状態を取得
    final sessionAsyncValue = ref.watch(sessionProvider);

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
            markers: markerStream.when(
              data: (markers) {
                return markers;
              },
              loading: () => {},
              error: (error, stack) => {},
            ),
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

              // マーカーが既に存在しているかの確認
              final markersExist = markerStream.maybeWhen(
                data: (markers) {
                  return markers.any(
                      (marker) => _isSameLocation(marker.position, position));
                },
                orElse: () => false,
              );

              if (markersExist) {
                // 既に存在している場合はモーダルを表示しない
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar() // 前の SnackBar を消す
                  ..showSnackBar(
                    const SnackBar(
                      content: Text("既にこの位置にマーカーがあります"),
                    ),
                  );
                return; // 処理を終了
              }

              // セッションの状態に基づいてボトムシートを表示
              sessionAsyncValue.when(
                  loading: () => null,
                  error: (error, stackTrace) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar() // 前の SnackBar を消す
                      ..showSnackBar(
                        SnackBar(content: Text('セッション確認エラー: $error')),
                      );
                  },
                  data: (sessionData) {
                    if (sessionData == null) {
                      // セッションが無効（未ログイン）な場合
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar() // 前の SnackBar を消す
                        ..showSnackBar(
                          const SnackBar(content: Text('ログインしてください')),
                        );
                      return;
                    } else {
                      // セッションが有効な場合

                      // モーダル表示時にボトムモーダルをアクティブにする
                      ref.read(bottomModalActiveProvider.notifier).state = true;

                      // モーダルを表示
                      showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return Consumer(
                              builder: (context, ref, child) {
                                // フォームにて、チップの選択状態を取得
                                final filterChip01 =
                                    ref.watch(filterChipProvider01);
                                final filterChip02 =
                                    ref.watch(filterChipProvider02);

                                // フォームにて、両替機の選択状態を取得
                                final exchangeMachine =
                                    ref.watch(exchangeMachineProvider);

                                // フォーム入力の値を取得
                                final shopName = ref.watch(shopNameProvider);

                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Center(child: Text("ガチャガチャ場所の登録")),
                                      const SizedBox(height: 8),
                                      TextField(
                                          decoration: const InputDecoration(
                                            hintText: "店名を入力してください",
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (String value) {
                                            // ユーザーの入力をProviderに保存
                                            ref
                                                .watch(
                                                    shopNameProvider.notifier)
                                                .state = value;
                                          }),
                                      const SizedBox(height: 8),
                                      const Text("何のガチャが多いか？"),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
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
                                                          filterChipProvider01
                                                              .notifier)
                                                      .toggleSelection(index);
                                                },
                                                // nullを防ぎ、falseを返す
                                                selected: filterChip01[index] ??
                                                    false,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text("ガチャ台数"),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
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
                                                          filterChipProvider02
                                                              .notifier)
                                                      .toggleSelection(index);
                                                },
                                                // nullを防ぎ、falseを返す
                                                selected: filterChip02[index] ??
                                                    false,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      CheckboxListTile(
                                        title: const Text("両替機がある"),
                                        value: exchangeMachine,
                                        onChanged: (bool? value) {
                                          if (value != null) {
                                            ref
                                                .watch(exchangeMachineProvider
                                                    .notifier)
                                                .state = value;
                                            // デバッグコンソールにメッセージを表示
                                            logger.d("両替機の状態が変更されました: $value");
                                          }
                                        },
                                        activeColor: Colors.green,
                                        checkColor: Colors.white,
                                      ),
                                      const SizedBox(height: 8),
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              // 何系のガチャが多いかのチェックされたリストを取得
                                              final selectedChoices01 = ref
                                                  .watch(filterChipProvider01
                                                      .notifier)
                                                  .getSelectedChoices();

                                              // ガチャ台数は何台かのチェックされたリストを取得
                                              final selectedChoices02 = ref
                                                  .watch(filterChipProvider02
                                                      .notifier)
                                                  .getSelectedChoices();

                                              // デバッグ用
                                              logger
                                                  .d("緯度:${position.latitude}");
                                              logger.d(
                                                  "経度:${position.longitude}");
                                              logger.d("お店の名前:$shopName");
                                              logger
                                                  .d("両替機の有無:$exchangeMachine");
                                              logger.d(
                                                  "何系のガチャが多いか:$selectedChoices01");
                                              logger.d(
                                                  "ガチャ台数は何台か:$selectedChoices02");

                                              // 入力漏れがあれば通知を行う
                                              if (shopName == "") {
                                                ScaffoldMessenger.of(context)
                                                  ..hideCurrentSnackBar() // 前の SnackBar を消す
                                                  ..showSnackBar(
                                                    const SnackBar(
                                                      content:
                                                          Text("店名を入力してください"),
                                                    ),
                                                  );
                                                return;
                                              }
                                              if (selectedChoices01.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                  ..hideCurrentSnackBar() // 前の SnackBar を消す
                                                  ..showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "何系のガチャが多いかにチェックを入れてください"),
                                                    ),
                                                  );
                                                return;
                                              }
                                              if (selectedChoices02.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                  ..hideCurrentSnackBar() // 前の SnackBar を消す
                                                  ..showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "ガチャの台数にチェックを入れてください"),
                                                    ),
                                                  );
                                              }

                                              final response = await http.post(
                                                Uri.parse(
                                                    '${ApiConfig.baseUrl}/registeringlocation'),
                                                headers: {
                                                  'Content-Type':
                                                      'application/json'
                                                },
                                                body: json.encode({
                                                  'lat': position.latitude,
                                                  'lng': position.longitude,
                                                  'shop_name': shopName,
                                                  'genre': selectedChoices01,
                                                  'unit': selectedChoices02,
                                                  'exchange_machine':
                                                      exchangeMachine,
                                                }),
                                              );

                                              // 正常終了時の処理
                                              if (response.statusCode == 200) {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                  if (ScaffoldMessenger.maybeOf(
                                                          context) !=
                                                      null) {
                                                    ScaffoldMessenger.of(
                                                        context)
                                                      ..hideCurrentSnackBar() // 前の SnackBar を消す
                                                      ..showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                "場所を登録できました")),
                                                      );
                                                  }
                                                  if (context.mounted) {
                                                    // showModalBottomSheetを閉じる
                                                    Navigator.pop(context);
                                                  }
                                                });
                                              } else {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                  if (ScaffoldMessenger.maybeOf(
                                                          context) !=
                                                      null) {
                                                    // サーバーからエラーが返ってきた場合
                                                    ScaffoldMessenger.of(
                                                        context)
                                                      ..hideCurrentSnackBar() // 前の SnackBar を消す
                                                      ..showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                "サーバーエラー: ${response.body}")),
                                                      );
                                                  }
                                                });
                                              }
                                            } catch (e) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                if (ScaffoldMessenger.maybeOf(
                                                        context) !=
                                                    null) {
                                                  // サーバーからエラーが返ってきた場合
                                                  ScaffoldMessenger.of(context)
                                                    ..hideCurrentSnackBar() // 前の SnackBar を消す
                                                    ..showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              "エラーが発生しました: $e")),
                                                    );
                                                }
                                              });
                                            }
                                          },
                                          child: const Text("場所を登録する"),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }).whenComplete(() {
                        ref.watch(bottomModalActiveProvider.notifier).state =
                            false;
                        // フォームの入力された値を削除
                        ref.watch(shopNameProvider.notifier).state = "";
                        ref.watch(exchangeMachineProvider.notifier).state =
                            false;

                        // FilterChipの選択状態をリセット
                        ref.read(filterChipProvider01.notifier).reset();
                        ref.read(filterChipProvider02.notifier).reset();
                      });
                    }
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
