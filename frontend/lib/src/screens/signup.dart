import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_map/main.dart';
import '../providers/provider.dart';
import 'package:dio/dio.dart';
import '../services/dio_client.dart';
import 'package:logger/logger.dart';

// Loggerインスタンスを作成
final logger = Logger();

// 新規登録表示
class SignUpPage extends ConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Providerから値を受け取る
    final signupInputID = ref.watch(signupInputIDProvider);
    final signupInputPassword = ref.watch(signupInputPasswordProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('新規登録'),
              const SizedBox(height: 15),
              TextFormField(
                  // テキスト入力のラベルを設定
                  decoration: const InputDecoration(labelText: 'ID'),
                  onChanged: (String value) {
                    // ユーザーの入力をProviderに保存
                    ref.watch(signupInputIDProvider.notifier).state = value;
                  }),
              TextFormField(
                  // テキスト入力のラベルを設定
                  decoration: const InputDecoration(labelText: 'パスワード'),
                  obscureText: true, // ここで入力を隠す
                  onChanged: (String value) {
                    // ユーザーの入力をProviderに保存
                    ref.watch(signupInputPasswordProvider.notifier).state =
                        value;
                  }),
              const SizedBox(height: 20),
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
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (ScaffoldMessenger.maybeOf(context) != null) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar() // 前のSnackBarを消す
                            ..showSnackBar(
                              const SnackBar(content: Text("新規登録ができました")),
                            );
                        }
                        if (context.mounted) {
                          context.go('/login/account');
                        }
                      });
                    } else {
                      // サーバーからエラーが返ってきた場合
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (ScaffoldMessenger.maybeOf(context) != null) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar() // 前のSnackBarを消す
                            ..showSnackBar(
                              SnackBar(
                                  content: Text("サーバーエラー: ${response.data}")),
                            );
                        }
                      });
                    }
                  } on DioException catch (e) {
                    logger.d("DioException: ${e.response?.data}");
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (ScaffoldMessenger.maybeOf(context) != null) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar() // 前のSnackBarを消す
                          ..showSnackBar(
                            SnackBar(
                                content:
                                    Text("エラーが発生しました: ${e.response?.data}")),
                          );
                      }
                    });
                  }
                },
                child: const Text('新規登録'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.go('/login');
                },
                child: const Text('既に登録済の方はこちら'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
