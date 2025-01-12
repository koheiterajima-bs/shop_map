import 'package:shop_map/main.dart';
import 'package:dio/dio.dart';
import '../services/dio_client.dart';
import 'package:logger/logger.dart';

// Loggerインスタンスを作成
final logger = Logger();

// セッション確認APIを呼び出す関数
// ユーザー名を画面表示させるために返り値を設定
Future<Map<String, dynamic>?> checkSession() async {
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
      final responseDataUser = response.data["user_id"];
      logger.d("これがresponseDataの返り値$responseData");
      logger.d("これがresponseDataのユーザーID$responseDataUser");
      return responseData;
    } else {
      return null;
    }
  } catch (e) {
    logger.d("セッションエラー: $e");
    return null;
  }
}
