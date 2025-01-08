import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

// Cookie管理を行うDioの実装

// Dioのインスタンスを作成
final Dio dio = Dio();
// CookieJarのインスタンスを作成(CookieJarは受け取ったCookieを保存するための箱)
final CookieJar cookieJar = CookieJar();

// CookieManagerをDioに追加
void setupDio() {
  dio.interceptors.add(CookieManager(cookieJar));
}
