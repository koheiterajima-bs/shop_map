import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider.dart';

// アカウントページ
class AccountPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isChecked = ref.watch(isCheckedProvider);

    // StreamProviderテスト用
    final counterStream = ref.watch(counterStreamProvider);

    // flavor確認用
    const flavor = String.fromEnvironment('flavor');

    return FutureBuilder(
        future: _checkSession(), // セッション確認APIを呼び出し
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError || snapshot.data == false) {
            // エラーまたは未ログイン状態ならログインページにリダイレクト
            Future.microtask(() {
              context.go('/login');
            });
            return Scaffold();
          } else {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('アカウントページ'),
                      SizedBox(height: 15),
                      Text(flavor),
                      ElevatedButton(
                          onPressed: () async {
                            try {
                              final response = await http.post(
                                Uri.parse('http://localhost:8080/logout'),
                                // Uri.parse('http://172.16.0.57:8080/logout'),
                              );

                              // 正常終了時の処理
                              if (response.statusCode == 200) {
                                // ログインページに移動
                                context.go('/login');
                              } else {
                                // サーバーからエラーが返ってきた場合
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('サーバーエラー: ${response.body}')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('エラーが発生しました: $e')),
                              );
                            }
                          },
                          child: Text('ログアウト')),
                      SizedBox(height: 15),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(isChecked ? "ON" : "OFF"),
                            Checkbox(
                              value: isChecked,
                              onChanged: (bool? checkedValue) {
                                if (checkedValue != null) {
                                  ref.read(isCheckedProvider.notifier).state =
                                      checkedValue;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: counterStream.when(
                          data: (count) => Text(
                            'カウント: $count 秒',
                            style: TextStyle(fontSize: 24),
                          ),
                          loading: () => CircularProgressIndicator(),
                          error: (error, stack) => Text('エラー: $error'),
                        ),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final response = await http.get(
                              Uri.parse('http://localhost:8080/get-marker'),
                              // Uri.parse('http://172.16.0.57:8080/get-marker'),
                            );

                            // 正常終了時の処理
                            if (response.statusCode == 200) {
                              // レスポンスボディをパースして表示
                              // print("レスポンスデータ: ${response.body}");

                              // レスポンスデータ全体をデコード
                              final responseData = jsonDecode(response.body);

                              // location配列を取得
                              final locations =
                                  responseData['location'] as List;

                              print(locations);

                              // 各locationからShopNameのみを抽出
                              final ShopNameList = locations
                                  .map((location) => location['ShopName'])
                                  .toList();

                              print("取得したShopのリスト: $ShopNameList");
                            } else {
                              // サーバーからエラーが返ってきた場合
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('サーバーエラー: ${response.body}')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("エラーが発生しました: $e")),
                            );
                          }
                        },
                        child: Text("マーカー全件取得"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}
// // アカウントページ
// class AccountPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: _checkSession(), // セッション確認APIを呼び出し
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Scaffold(
//               body: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           } else if (snapshot.hasError || snapshot.data == false) {
//             // エラーまたは未ログイン状態ならログインページにリダイレクト
//             Future.microtask(() {
//               context.go('/login');
//             });
//             return Scaffold();
//           } else {
//             return Scaffold(
//               body: Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text('アカウントページ'),
//                       SizedBox(height: 15),
//                       ElevatedButton(
//                           onPressed: () async {
//                             try {
//                               final response = await http.post(
//                                 Uri.parse('http://localhost:8080/logout'),
//                                 // Uri.parse('http://172.16.0.57:8080/logout'),
//                               );

//                               // 正常終了時の処理
//                               if (response.statusCode == 200) {
//                                 // ログインページに移動
//                                 context.go('/login');
//                               } else {
//                                 // サーバーからエラーが返ってきた場合
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                       content:
//                                           Text('サーバーエラー: ${response.body}')),
//                                 );
//                               }
//                             } catch (e) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('エラーが発生しました: $e')),
//                               );
//                             }
//                           },
//                           child: Text('ログアウト')),
//                       SizedBox(height: 15),
//                       Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(isChecked ? "ON" : "OFF"),
//                             Checkbox(
//                               value: isChecked,
//                               onChanged: (bool? checkedValue) {
//                                 if (checkedValue != null) {
//                                   ref.read(_isCheckedProvider.notifier).state =
//                                       checkedValue;
//                                 }
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }
//         });
//   }
// }

// セッション確認APIを呼び出す関数
Future<bool> _checkSession() async {
  try {
    final response =
        await http.get(Uri.parse('http://localhost:8080/check-session'),
            // Uri.parse('http://172.16.0.57:8080/check-session'),
            headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['message'] == 'ログイン済み';
    } else {
      return false;
    }
  } catch (e) {
    print("エラー: $e");
    return false;
  }
}
