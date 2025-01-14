import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_map/main.dart';
import '../services/dio_client.dart';
import '../services/session.dart';

// アカウントページ
class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      Text("ユーザー名: $userId"),
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
                              final responseDataUser = response.data["user_id"];
                              logger.d(
                                  "これがセッションと比較して取得したユーザー一覧:$responseDataUser");

                              // これが取得できない！！！！(1/14ここから再開！！！！)
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("エラーが発生しました: $e")),
                            );
                          }
                        },
                        child: const Text("セッションと一致するユーザーの場所取得"),
                      ),
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
