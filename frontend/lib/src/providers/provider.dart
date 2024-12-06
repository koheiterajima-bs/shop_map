// プロバイダー定義ファイル(これは没？)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ボトムナビゲーションの切り替えカウント用
final counterProvider = StateProvider<int>((ref) => 0);
