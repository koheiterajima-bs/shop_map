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
// final markerStreamProvider = StreamProvider<List<Marker>>

// 以下テスト用(後で消す)
// account.dartに記載
final AutoDisposeStateProvider<bool> isCheckedProvider =
    StateProvider.autoDispose((ref) {
  return false;
});

// map.dartに記載
final counterStreamProvider = StreamProvider<int>((ref) async* {
  int count = 0;
  while (true) {
    await Future.delayed(Duration(seconds: 1));
    count++;
    print('現在の秒数: $count');
    yield count;
  }
});
