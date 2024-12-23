import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// アカウントページ
class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              body: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('これはアカウントページです'),
              ),
            );
          }
        });
  }
}

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
