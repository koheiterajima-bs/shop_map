import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_map/main.dart';
import '../providers/provider.dart';
import 'package:dio/dio.dart';
import '../services/dio_client.dart';

// ログイン画面表示
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Providerから値を受け取る
    final loginInputID = ref.watch(loginInputIDProvider);
    final loginInputPassword = ref.watch(loginInputPasswordProvider);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ログイン'),
              SizedBox(height: 15),
              TextFormField(
                  // テキスト入力のラベルを設定
                  decoration: InputDecoration(labelText: 'ID'),
                  onChanged: (String value) {
                    // ユーザーの入力をProviderに保存
                    ref.watch(loginInputIDProvider.notifier).state = value;
                  }),
              TextFormField(
                  // テキスト入力のラベルを設定
                  decoration: InputDecoration(labelText: 'パスワード'),
                  obscureText: true, // 入力を隠す
                  onChanged: (String value) {
                    // ユーザーの入力をProviderに保存
                    ref.watch(loginInputPasswordProvider.notifier).state =
                        value;
                  }),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Dioにてログイン処理を行う
                    final response = await dio
                        .post('${ApiConfig.baseUrl}/login', data: {
                      'user_id': loginInputID,
                      'password': loginInputPassword
                    });
                    print("Response data: ${response.data}");

                    // Cookieの動作確認(Cookieを受け取れているか)
                    // final cookies = await cookieJar
                    //     .loadForRequest(Uri.parse(ApiConfig.baseUrl));
                    // print("Cookies: $cookies");

                    // 正常終了時の処理
                    if (response.statusCode == 200) {
                      // 以下のloginページ遷移を行う前にSnackBarを表示させる
                      Future.microtask(() {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("ログインしました")),
                        );
                      });
                      // 遷移先ページに移動
                      Future.microtask(() {
                        context.go('/login/account');
                      });
                    } else {
                      // サーバーからエラーが返ってきた場合
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('サーバーエラー: ${response.data}')),
                      );
                    }
                  } on DioException catch (e) {
                    print('DioException: ${e.response?.data}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('エラーが発生しました: ${e.response?.data}')),
                    );
                  }
                },
                child: Text('ログイン'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.go('/login/signup');
                },
                child: Text('新規登録の場合はこちら'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
