import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_map/main.dart';
import 'package:dio/dio.dart';
import '../services/dio_client.dart';

// アカウントページ
class AccountPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // 以下のloginページ遷移を行う前にSnackBarを表示させる
            Future.microtask(() {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('セッション確認ができませんでした')),
              );
            });
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
                              final response = await dio.post(
                                '${ApiConfig.baseUrl}/logout',
                              );

                              // 正常終了時の処理
                              if (response.statusCode == 200) {
                                // 以下のloginページ遷移を行う前にSnackBarを表示させる
                                Future.microtask(() {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('ログアウトしました')),
                                  );
                                });
                                // ログインページに移動
                                Future.microtask(() {
                                  context.go('/login');
                                });
                              } else {
                                // サーバーからエラーが返ってきた場合
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          // Text('サーバーエラー: ${response.body}')
                                          Text('サーバーエラー: ${response.data}')),
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
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final response = await http.get(
                              // Uri.parse('http://localhost:8080/get-marker'),
                              // Uri.parse('http://172.16.0.57:8080/get-marker'),
                              // Androidエミュレータ
                              // Uri.parse('http://10.0.2.2:8080/get-marker'),
                              Uri.parse('${ApiConfig.baseUrl}/get-marker'),
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
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final response = await http.get(
                              Uri.parse('${ApiConfig.baseUrl}/get-user'),
                            );

                            // 正常終了時の処理
                            if (response.statusCode == 200) {
                              // レスポンスデータ全体をデコード
                              final responseData = jsonDecode(response.body);

                              // user配列を取得
                              final users = responseData['user'] as List;

                              // 各userからuser_idのみを抽出
                              final userNameList =
                                  users.map((user) => user['user_id']).toList();

                              print("取得したUserのリスト: $userNameList");
                            } else {
                              // サーバーからエラーが返ってきた場合
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("サーバーエラー: ${response.body}"),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("エラーが発生しました: $e")),
                            );
                          }
                        },
                        child: Text("ユーザー情報全件取得"),
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

// セッション確認APIを呼び出す関数
Future<bool> _checkSession() async {
  try {
    final response = await dio.get(
      '${ApiConfig.baseUrl}/check-session',
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      // Dioではレスポンスのデータは自動的にデコードされる
      final responseData = response.data;
      return responseData['message'] == 'ログイン済み';
    } else {
      return false;
    }
  } catch (e) {
    print("セッションのエラー？？？: $e");
    return false;
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
