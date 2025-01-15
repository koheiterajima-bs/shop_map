import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_map/main.dart';
import '../services/dio_client.dart';
import '../services/session.dart';
import '../providers/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// アカウントページ
class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 自身の場所投稿一覧取得
    final userLocationAsync = ref.watch(userLocationProvider);

    return FutureBuilder<Map<String, dynamic>?>(
        future: checkSession(), // セッション確認APIを呼び出し
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            // セッション確認失敗時の処理
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (ScaffoldMessenger.maybeOf(context) != null) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar() // 前のSnackBarを消す
                  ..showSnackBar(
                    const SnackBar(content: Text('セッション確認ができませんでした')),
                  );
              }
              if (context.mounted) {
                context.go('/login');
              }
            });
            return const Scaffold();
          } else {
            // セッション確認ができた場合
            final userData = snapshot.data;
            final userId = userData?["user_id"];

            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('アカウントページ'),
                      // ここにユーザー名を表示する
                      Text("$userIdさん、ご利用ありがとうございます。"),
                      const SizedBox(height: 15),
                      ElevatedButton(
                          onPressed: () async {
                            try {
                              final response = await dio.post(
                                '${ApiConfig.baseUrl}/logout',
                              );
                              // ログアウト処理
                              // 正常終了時の処理
                              if (response.statusCode == 200) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (ScaffoldMessenger.maybeOf(context) !=
                                      null) {
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar() // 前のSnackBarを消す
                                      ..showSnackBar(
                                        const SnackBar(
                                            content: Text('ログアウトしました')),
                                      );
                                  }
                                  if (context.mounted) {
                                    context.go('/login');
                                  }
                                });
                              } else {
                                // サーバーからエラーが返ってきた場合
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (ScaffoldMessenger.maybeOf(context) !=
                                      null) {
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar() // 前のSnackBarを消す
                                      ..showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'サーバーエラー: ${response.data}')),
                                      );
                                  }
                                  if (context.mounted) {
                                    context.go('/login');
                                  }
                                });
                              }
                            } catch (e) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (ScaffoldMessenger.maybeOf(context) !=
                                    null) {
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar() // 前のSnackBarを消す
                                    ..showSnackBar(
                                      SnackBar(content: Text('エラーが発生しました: $e')),
                                    );
                                }
                              });
                            }
                          },
                          child: const Text('ログアウト')),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final response = await dio.get(
                                '${ApiConfig.baseUrl}/get-user-location',
                                data: {
                                  'user_id': userId,
                                });

                            // 正常終了時の処理
                            if (response.statusCode == 200) {
                              final responseDataLocation =
                                  response.data["location"];
                              // final responseDataShopName =
                              //     responseDataLocation["ShopName"];
                              logger.d("これが取得したデータそのまま:$response");
                              logger.d("取得した場所:$responseDataLocation");
                              // logger.d("取得した店名:$responseDataShopName");
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("エラーが発生しました: $e")),
                            );
                          }
                        },
                        child: const Text("セッションと一致するユーザーの場所取得"),
                      ),
                      const SizedBox(height: 15),
                      Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.grey),
                          ),
                          child: userLocationAsync.when(
                            data: (userLocations) {
                              return ListView.builder(
                                itemCount: userLocations.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text("$index"),
                                  );
                                },
                              );
                            },
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (error, stackTrace) =>
                                Center(child: Text("エラー: $error")),
                          )),
                      // Container(
                      //   height: 200,
                      //   decoration: BoxDecoration(
                      //     color: Colors.grey[200],
                      //     border: Border.all(color: Colors.grey),
                      //   ),
                      // child: ListView.builder(
                      //     itemCount: userLocation.locations.length,
                      //     itemBuilder: (context, index) {
                      //       return ListTile(
                      //         title: Text("アイテム$index"),
                      //       );
                      //     }),

                      // child: ListView.builder(
                      //   itemCount: 20,
                      //   itemBuilder: (context, index) {
                      //     return Slidable(
                      //       key: ValueKey(index),

                      //       // スライド方向を設定
                      //       direction: Axis.horizontal,

                      //       // 左方向のアクション
                      //       startActionPane: ActionPane(
                      //         motion: const ScrollMotion(),
                      //         children: [
                      //           SlidableAction(
                      //             onPressed: (context) {
                      //               // 編集アクション
                      //               ScaffoldMessenger.of(context)
                      //                   .showSnackBar(
                      //                 SnackBar(content: Text('hogeを編集しました')),
                      //               );
                      //             },
                      //             backgroundColor: Colors.blue,
                      //             foregroundColor: Colors.white,
                      //             icon: Icons.edit,
                      //             label: '編集',
                      //           ),
                      //         ],
                      //       ),

                      //       // 右方向のアクション
                      //       endActionPane: ActionPane(
                      //         motion: const ScrollMotion(),
                      //         children: [
                      //           SlidableAction(
                      //             onPressed: (context) {
                      //               // 削除アクション
                      //               ScaffoldMessenger.of(context)
                      //                   .showSnackBar(
                      //                 SnackBar(content: Text('hogeを削除しました')),
                      //               );
                      //             },
                      //             backgroundColor: Colors.red,
                      //             foregroundColor: Colors.white,
                      //             icon: Icons.delete,
                      //             label: '削除',
                      //           ),
                      //         ],
                      //       ),

                      //       // スライド可能なリストアイテムの内容
                      //       child: ListTile(
                      //         title: Text("hoge"),
                      //       ),
                      //     );
                      //   },
                      // ),
                      // ),

                      // ElevatedButton(
                      //   onPressed: () async {
                      //     try {
                      //       final response = await http.get(
                      //         Uri.parse('${ApiConfig.baseUrl}/get-marker'),
                      //       );

                      //       // 正常終了時の処理
                      //       if (response.statusCode == 200) {
                      //         // レスポンスボディをパースして表示
                      //         // print("レスポンスデータ: ${response.body}");

                      //         // レスポンスデータ全体をデコード
                      //         final responseData = jsonDecode(response.body);

                      //         // location配列を取得
                      //         final locations =
                      //             responseData['location'] as List;

                      //         print(locations);

                      //         // 各locationからShopNameのみを抽出
                      //         final ShopNameList = locations
                      //             .map((location) => location['ShopName'])
                      //             .toList();

                      //         print("取得したShopのリスト: $ShopNameList");
                      //       } else {
                      //         // サーバーからエラーが返ってきた場合
                      //         ScaffoldMessenger.of(context).showSnackBar(
                      //           SnackBar(
                      //               content: const Text('サーバーエラー: ${response.body}')),
                      //         );
                      //       }
                      //     } catch (e) {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(content: const Text("エラーが発生しました: $e")),
                      //       );
                      //     }
                      //   },
                      //   child: const Text("マーカー全件取得"),
                      // ),
                      const SizedBox(height: 15),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     try {
                      //       final response = await http.get(
                      //         Uri.parse('${ApiConfig.baseUrl}/get-user'),
                      //       );

                      //       // 正常終了時の処理
                      //       if (response.statusCode == 200) {
                      //         // レスポンスデータ全体をデコード
                      //         final responseData = jsonDecode(response.body);

                      //         // user配列を取得
                      //         final users = responseData['user'] as List;

                      //         // 各userからUserIDのみを抽出
                      //         final userNameList =
                      //             users.map((user) => user['UserID']).toList();

                      //         print("取得したUserのリスト: $userNameList");
                      //       } else {
                      //         // サーバーからエラーが返ってきた場合
                      //         ScaffoldMessenger.of(context).showSnackBar(
                      //           SnackBar(
                      //             content: const Text("サーバーエラー: ${response.body}"),
                      //           ),
                      //         );
                      //       }
                      //     } catch (e) {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(content: const Text("エラーが発生しました: $e")),
                      //       );
                      //     }
                      //   },
                      //   child: const Text("ユーザー情報全件取得"),
                      // ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}
