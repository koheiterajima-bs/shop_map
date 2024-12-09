import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 新規登録表示
class SignUpPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
