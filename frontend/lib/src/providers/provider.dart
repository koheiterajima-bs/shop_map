import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Googleマップコントローラーの状態管理
// 非同期で実装？(後々、データベースやバックエンドから初期設定を取得する？)
// コントローラーの状態を管理するためにStateProviderを定義
// マップが画面に表示されるとき、GoogleMapControllerはonMapCreatedというタイミングで生成される
final googleMapControllerProvider =
    StateProvider<GoogleMapController?>((ref) => null);

// マップの初期位置の状態管理
// 現在位置からスタートさせたいので、後々非同期にしたい、一旦StateProviderで実装？
final mapCenterProvider =
    StateProvider<LatLng>((ref) => const LatLng(45.521563, -122.677433));

// カメラの初期位置(表示画面の中心となるところ)

// マップ作成イベントの管理