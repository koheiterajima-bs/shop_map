import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/provider.dart';

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
                  onChanged: (String value) {
                    // ユーザーの入力をProviderに保存
                    ref.watch(loginInputPasswordProvider.notifier).state =
                        value;
                  }),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final response = await http.post(
                      Uri.parse('http://localhost:8080/login'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({
                        'user_id': loginInputID,
                        'password': loginInputPassword
                      }),
                    );

                    // 正常終了時の処理
                    if (response.statusCode == 200) {
                      // 遷移先ページに移動
                      context.go('/login/account');
                    } else {
                      // サーバーからエラーが返ってきた場合
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('サーバーエラー: ${response.body}')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('エラーが発生しました: $e')),
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
