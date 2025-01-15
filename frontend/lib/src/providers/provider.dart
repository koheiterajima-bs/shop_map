import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shop_map/main.dart';
import '../services/session.dart';
import '../services/dio_client.dart';

// Googleマップコントローラーの状態管理
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

// ログイン画面にてIDを保持するProvider
final loginInputIDProvider = StateProvider<String>((ref) => "");

// ログイン画面にてPasswordを保持するProvider
final loginInputPasswordProvider = StateProvider<String>((ref) => "");

// 新規登録画面にてIDを保持するProvider
final signupInputIDProvider = StateProvider<String>((ref) => "");

// 新規登録画面にてPasswordを保持するProvider
final signupInputPasswordProvider = StateProvider<String>((ref) => "");

// ボトムモーダルの活性/非活性管理
final bottomModalActiveProvider = StateProvider<bool>((ref) => false);

// FilterChip01の選択状態を管理するProvider
final filterChipProvider01 =
    StateNotifierProvider<FilterChipNotifier01, Map<int, bool>>((ref) {
  return FilterChipNotifier01();
});

class FilterChipNotifier01 extends StateNotifier<Map<int, bool>> {
  FilterChipNotifier01()
      : super(Map.fromEntries(List.generate(
            choices01.length, (index) => MapEntry(index, false))));

  // 選択状態を切り替えるメソッド
  void toggleSelection(int index) {
    state = {
      ...state,
      index: !(state[index] ?? false),
    };
  }

  // 状態をリセットするメソッド
  void reset() {
    state = Map.fromEntries(
      List.generate(choices01.length, (index) => MapEntry(index, false)),
    );
  }

  // 選択されている項目を取得するメソッド
  List<String> getSelectedChoices() {
    return state.entries
        .where((entry) => entry.value)
        .map((entry) => choices01[entry.key])
        .toList();
  }
}

// チップの選択肢(何系のガチャガチャが多いか)
List<String> choices01 = ["キャラ", "ミニチュア", "マニアック"];

// FliterChip02の選択状態を管理するProvider
final filterChipProvider02 =
    StateNotifierProvider<FilterChipNotifier02, Map<int, bool>>((ref) {
  return FilterChipNotifier02();
});

class FilterChipNotifier02 extends StateNotifier<Map<int, bool>> {
  FilterChipNotifier02()
      : super(Map.fromEntries(List.generate(
            choices02.length, (index) => MapEntry(index, false))));

  // 選択状態を切り替えるメソッド(いずれか1つだけ選択可能)
  void toggleSelection(int index) {
    state = {
      for (var key in state.keys)
        key: key == index, // 選択されたindexをtrue、それ以外をfalse
    };
  }

  // 状態をリセットするメソッド
  void reset() {
    state = Map.fromEntries(
      List.generate(choices02.length, (index) => MapEntry(index, false)),
    );
  }

  // 選択されている項目を取得するメソッド
  List<String> getSelectedChoices() {
    return state.entries
        .where((entry) => entry.value)
        .map((entry) => choices02[entry.key])
        .toList();
  }
}

// チップの選択肢(ガチャ台数は何台か)
List<String> choices02 = ["0〜10台", "11〜50台", "51〜100台", "それ以上"];

// 店名を保持するProvider
final shopNameProvider = StateProvider<String>((ref) => "");

// ガチャのジャンルを保持するProvider
final genreProvider = StateProvider<String>((ref) => "");

// ガチャの台数を保持するProvider
final unitProvider = StateProvider<String>((ref) => "");

// 両替機の有無を保持するProvider
final AutoDisposeStateProvider<bool> exchangeMachineProvider =
    StateProvider.autoDispose((ref) {
  return false;
});

// バックエンドから取得してきたマーカー情報をポーリングにて取得
// final markerStreamProvider = StreamProvider<Set<Marker>>((ref) async* {
final markerStreamProvider = StreamProvider<Set<CustomMarker>>((ref) async* {
  while (true) {
    await Future.delayed(const Duration(seconds: 2)); // 2秒ごとにリクエスト
    final response =
        await http.get(Uri.parse('${ApiConfig.baseUrl}/get-marker'));
    if (response.statusCode == 200) {
      // レスポンスデータ全体をデコード
      final responseData = jsonDecode(response.body);

      // location配列を取得
      final locations = responseData["location"] as List;

      // カスタムマーカーリストを生成
      final customMarkers = locations.map((location) {
        // リスト型をjoinで文字列変換させたいが、うまくいかない、、、
        // 最初にフロントの入力するところから見直してみる
        // List<String> genre = [];
        // if (location["Genre"] is List) {
        //   genre = List<String>.from(location["Genre"]);
        // } else {
        //   // もしジャンルがListでなければ空リストを設定、もしくはデフォルト値を設定
        //   logger.d("Genre is not a List: ${location["Genre"]}");
        //   genre = ["不明なジャンル"];
        // }

        // ジャンルを結合
        // String genreString = genre.join(" ");

        final details = [
          "${location["ShopName"]}",
          "ジャンル:${location["Genre"]}",
          // "ジャンル:${genre.join(" ")}",
          // "ジャンル:$genre",
          // "ジャンル:$genreString",
          "ガチャ台数: ${location["Unit"]}",
          "両替機の有無: ${location["ExchangeMachine"]}",
        ];

        final marker = Marker(
          markerId: MarkerId(location["ID"].toString()),
          position: LatLng(
            location["Lat"] as double,
            location["Lng"] as double,
          ),
        );

        return CustomMarker(marker: marker, details: details);
      }).toSet();

      yield customMarkers;
    } else {
      throw Exception("マーカー取得に失敗しました");
    }
  }
});

// markerStreamProviderがmarkerとdetailsを返せるようにするためのデータクラス
class CustomMarker {
  final Marker marker;
  final List<String> details;

  CustomMarker({required this.marker, required this.details});
}

// マップフォームの表示有無をセッションによって切り替える
final sessionProvider = StreamProvider<Map<String, dynamic>?>((ref) async* {
  while (true) {
    // セッション状態を取得する非同期関数
    await Future.delayed(const Duration(seconds: 2)); // 2秒ごとに取得
    yield await checkSession();
  }
});

// // バックエンドから取得してきた自身の場所投稿一覧を取得
// final userLocationProvider = FutureProvider<List<UserLocation>>((ref) async {
//   final response =
//       await dio.get('${ApiConfig.baseUrl}/get-user-location', data: {
//     // 'user_id': userId,
//     'user_id': "map_sample", // 試しにハードコーディングにて行う
//   });

//   // 正常終了時の処理
//   if (response.statusCode == 200) {
//     // 取得した場所のデータ
//     final responseData = response.data;
//     logger.d("取得した場所:$responseData");

//     // ここ以下が出力されない

//     // location配列を取得
//     // final locations = responseData["location"] as List<UserLocation>;
//     // final locations = responseData["location"];
//     // logger.d("場所の出力(出元:provider.dart):$locations");

//     // logger.d("店名:${locations["ShopName"]}");

//     // JSONからデータをリストに追加
//     // final newData = locations
//     //     .map((location) =>
//     //         UserLocation.fromJson(location as Map<String, dynamic>))
//     //     .toList();

//     final locations =
//         responseData["location"] as List<dynamic>; // `locations`をリストとしてキャスト
//     logger.d("これはprovider.dartのlocationsです:$locations");

//     logger.d("これはprovider.dartのlocationの0番目です:${locations[0]}");
//     // final shopNames = locations.map((location) {
//     //   return (location as Map<String, dynamic>)["ShopName"];
//     // }).toList();

//     // logger.d("ShopNameリスト: $shopNames");
//     logger.d("数は？:${locations.length}");

//     // 場所のリストを生成
//     final userLocations = locations.map((location) {
//       return location;
//     }).toSet();
//   } else {
//     throw Exception("セッションユーザーの場所の取得に失敗しました");
//   }
// });

// バックエンドから取得してきた自身の場所投稿一覧をポーリングにて取得
final userLocationProvider = StreamProvider<List<dynamic>>((ref) async* {
  while (true) {
    await Future.delayed(const Duration(seconds: 2)); // 2秒ごとにリクエスト
    final response =
        await dio.get('${ApiConfig.baseUrl}/get-user-location', data: {
      // 'user_id': userId,
      'user_id': "map_sample", // 試しにハードコーディングにて行う
    });

    // 正常終了時の処理
    if (response.statusCode == 200) {
      // 取得した場所のデータ
      final responseData = response.data;
      logger.d("取得した場所:$responseData");

      // ここ以下が出力されない

      // location配列を取得
      // final locations = responseData["location"] as List<UserLocation>;
      // final locations = responseData["location"];
      // logger.d("場所の出力(出元:provider.dart):$locations");

      // logger.d("店名:${locations["ShopName"]}");

      // JSONからデータをリストに追加
      // final newData = locations
      //     .map((location) =>
      //         UserLocation.fromJson(location as Map<String, dynamic>))
      //     .toList();

      final locations =
          responseData["location"] as List<dynamic>; // `locations`をリストとしてキャスト
      logger.d("これはprovider.dartのlocationsです:$locations");

      logger.d("これはprovider.dartのlocationの0番目です:${locations[0]}");
      // final shopNames = locations.map((location) {
      //   return (location as Map<String, dynamic>)["ShopName"];
      // }).toList();

      // logger.d("ShopNameリスト: $shopNames");
      logger.d("数は？:${locations.length}");

      // 場所のリストを生成
      final userLocations = locations.map((location) {
        return location;
      }).toSet();

      yield userLocations;
    } else {
      throw Exception("セッションユーザーの場所の取得に失敗しました");
    }
  }
});

// 自身の場所投稿データクラス
class UserLocation {
  final int id;
  final String createdAt;
  final String updatedAt;
  final String deletedAt;
  final double lat;
  final double lng;
  final String shopName;
  final List<String> genre;
  final List<String> unit;
  final bool exchangeMachine;
  final String accountName;

  // インスタンス生成
  UserLocation({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.lat,
    required this.lng,
    required this.shopName,
    required this.genre,
    required this.unit,
    required this.exchangeMachine,
    required this.accountName,
  });

  // ファクトリーコンストラクタ
  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
        id: json['id'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        deletedAt: json['deletedAt'],
        lat: json['lat'],
        lng: json['lng'],
        shopName: json['shopName'],
        genre: List<String>.from(json['genre']),
        unit: List<String>.from(json['unit']),
        exchangeMachine: json['exchangeMachine'],
        accountName: json['accountName']);
  }
}

// 取得データ
// 取得した場所:
// [{ID: 29, CreatedAt: 2025-01-14T09:20:23.703Z, UpdatedAt: 2025-01-14T09:20:23.703Z, DeletedAt: null, Lat: 35.68564856089414, Lng: 139.74161580204964, ShopName: 半蔵門駅, Genre: ["キャラ", "ミニチュア"], Unit: ["0〜10台"], ExchangeMachine: true, AccountName: map_sample},
//  {ID: 30, CreatedAt: 2025-01-15T01:56:15.058Z, UpdatedAt: 2025-01-15T01:56:15.058Z, DeletedAt: null, Lat: 35.71105235635439, Lng: 139.77357901632786, ShopName: 京成上野駅, Genre: ["キャラ", "ミニチュア"], Unit: ["11〜50台"], ExchangeMachine: true, AccountName: map_sample}]