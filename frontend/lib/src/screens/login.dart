import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ログイン画面表示
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                decoration: InputDecoration(labelText: 'ID'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'パスワード'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Text('hoge');
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
