import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_map/main.dart';
import '../providers/provider.dart';
import '../services/dio_client.dart';

// 新規登録表示
class SignUpPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Providerから値を受け取る
    final signupInputID = ref.watch(signupInputIDProvider);
    final signupInputPassword = ref.watch(signupInputPasswordProvider);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('新規登録'),
              SizedBox(height: 15),
              TextFormField(
                  // テキスト入力のラベルを設定
                  decoration: InputDecoration(labelText: 'ID'),
                  onChanged: (String value) {
                    // ユーザーの入力をProviderに保存
                    ref.watch(signupInputIDProvider.notifier).state = value;
                  }),
              TextFormField(
                  // テキスト入力のラベルを設定
                  decoration: InputDecoration(labelText: 'パスワード'),
                  obscureText: true, // ここで入力を隠す
                  onChanged: (String value) {
                    // ユーザーの入力をProviderに保存
                    ref.watch(signupInputPasswordProvider.notifier).state =
                        value;
                  }),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Dioにてサインアップ処理を行う
                    final response = await dio
                        .post('${ApiConfig.baseUrl}/login/signup', data: {
                      'user_id': signupInputID,
                      'password': signupInputPassword
                    });

                    // 正常終了時の処理
                    if (response.statusCode == 200) {
                      // 以下のloginページ遷移を行う前にSnackBarを表示させる
                      Future.microtask(() {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("新規登録ができました")),
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
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('エラーが発生しました: $e')),
                    );
                  }
                },
                child: Text('新規登録'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.go('/login');
                },
                child: Text('既に登録済の方はこちら'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
