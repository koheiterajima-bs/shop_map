import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// Googleマップコントローラーの状態管理
// 非同期で実装？(後々、データベースやバックエンドから初期設定を取得する？)
// コントローラーの状態を管理するためにStateProviderを定義
// マップが画面に表示されるとき、GoogleMapControllerはonMapCreatedというタイミングで生成される
final googleMapControllerProvider =
    StateProvider<GoogleMapController?>((ref) => null);

// マップの初期位置の状態管理
final mapCenterProvider = StateProvider<LatLng>(
    (ref) => const LatLng(35.68021168333, 139.7576692371));

// 現在位置を取得するプロバイダー
final currentLocationProvider = FutureProvider<LatLng>((ref) async {
  // 位置情報サービスの許可をリクエスト
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception("位置情報サービスが無効です");
  }

  // 権限のリクエスト
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception("位置情報の権限が拒否されました");
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception("位置情報の権限が永久に拒否されています");
  }

  // 現在位置を取得
  Position position = await Geolocator.getCurrentPosition();
  return LatLng(position.latitude, position.longitude);
});

// 現在のマーカーセットを管理するプロバイダー
final markersProvider = StateProvider<Set<Marker>>((ref) => {});

// ログイン画面にてIDを保持するProvider
final loginInputIDProvider = StateProvider<String>((ref) => "");

// ログイン画面にてPasswordを保持するProvider
final loginInputPasswordProvider = StateProvider<String>((ref) => "");

// 新規登録画面にてIDを保持するProvider
final signupInputIDProvider = StateProvider<String>((ref) => "");

// 新規登録画面にてPasswordを保持するProvider
final signupInputPasswordProvider = StateProvider<String>((ref) => "");
