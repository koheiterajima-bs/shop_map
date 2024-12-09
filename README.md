# 何をするか
## やりたいこと(個人飲食店検索アプリ)
- 会員機能
  - ログイン/ログアウト
  - 個人情報登録

- お店登録機能
  - 名称検索登録
    - ぐるなびAPI？ホットペッパーAPI？
  - 地図検索登録
    - Google Maps APIを使う、ピン範囲周りの設定が分かれば、行けそう？
  - 登録内容
    - 星数
    - メモ
    - タグ
    - 写真

## やりたいこと(ガチャガチャ検索アプリ)
- 会員機能(ログイン/ログアウト)
- 投稿機能
- 何台ある(ドロップダウン？)、何のガチャがある、どれぐらいの残量あるか、両替機(チェックボックス)あるかどうか
- 何系が多いか(キャラもの、ミニチュア系)
- 各店の口コミ、掲示板、場所の登録機能(ログインしないと使えない)

### 必要なページ
- ホーム(各メニュー)
- 地図
  - 地図から登録
  - 登録場所に関する口コミ投稿ページ
- アカウント(ログイン/新規登録)

### どの技術の勉強が必要か
- データベース(MySQL)
- パスワードのハッシュ化(bcrypt)
- HTTPフレームワーク(Gin)
- ホットリロード(Air)
- リフレッシュトークン
- セキュリティ(HTTPSを使用、.envファイルでシークレットキーやデータベース情報を管理)

## 予定(1月末まで)(12/4スタート)
- バックエンド
  - ログイン機能(フロント側は一旦HTMLにて実装？)
    - フロント部分を簡素に作成->完了
    - DockerにてMySQLのコンテナ作成->完了
    - DockerにてGolangのコンテナ作成->完了
    - GolangにてMySQLに接続し、コマンドにMySQLデータ取得->完了
    - GolangのホットリロードAirを導入->完了
    - Gormを導入し、データベース作成の記述を行い、元々ある.sqlファイルとdocker-composeファイルのバインドを削除->完了
    - Ginを使い、HTTPリクエストの記述を行う->完了
    - 暗号化、ミドルウェア部分の記述を行う->
    - ログイン機能の実装を行う->
    - bcryptを使ったパスワード認証

    database.goのInitをinitに書き換え、main.goの中はルーティングのみに変える
    ルーティング、暗号化の実装を行う
    Redisとは

  - 投稿機能

- フロントエンド
  - 各画面作成
    - GoRouterを設定し、画面だけ作成->完了
  - 各画面の実装
    - Riverpodのインストールと設定->完了
    - ボトムナビゲーションを実装し、各画面に遷移->完了
    - Google Maps API(google_maps_flutter)を使い、画面に地図表示->完了
    現在地を取得し、表示！！！(12/8ここから再開！！！)

### 予定
- 12/4-8の週：ログイン機能の実装、ボトムナビゲーションの作成
- 12/9の週：フロントとバックの繋ぎ込み
- 12/ ：


## 段階の踏み方
- バックエンド
  - Flutterの画面にて入力したものをgoを通じてmysqlに接続し、保存されるようにする

- フロントエンド
  - 画面だけ作成
  - ボトムナビゲーションバーにより、画面推移を作成
  - Google Maps APIを用い、地図表示
  - 検索機能実装
  - バックエンドとの繋ぎ込み(ログイン・新規登録、投稿機能)

## 学んだこと
- MVCモデル
  - Model:ビジネスロジックを担当する部分、DBとやりとりしたり、データの登録・更新・削除を行う
  - View:表示や入出力などのUIを担当する部分
  - Controller:ModelとViewの制御を担当する部分、Modelにデータ処理の指示を出したり、Viewに画面表示の指示を出したりする
- Dockerのボリューム
  - 外部HDDのようなイメージ
  - サービス内に作成するのと、サービス外に作成するのでは何が異なるか？->サービス内だとコンテナ(サービス)削除時にボリュームも一緒に削除されてしまう
- Gorm導入のメリット
  - MySQLコンテナ起動時に必要なデータベースやテーブルを簡単に管理できる
  - Gormを導入しないと、.shファイルにデータベースの初期設定を記述し、docker-composeのボリューム設定にてバインドしなくてはならない
- Navigatorとは
  - Flutterでは、画面遷移を管理するためにNavigatorという仕組みを使う
  - GlobalKey
    - アプリ内の特定のウィジェットを一意に識別するためのラベルのようなもの
    - 通常、FlutterのウィジェットはBuildContextを使って見つけるが、複雑な構造の中で特定のウィジェットを直接参照したい場合にGlobalKeyを使う
- GoのフレームワークGin導入のメリット
  - HTTPリクエストに対するルーティングを非常に簡単に記述できる
  - GET,POST,PUT,DELETEなどのメソッドに対応したエンドポイントをシンプルに定義でき、ミドルウェアの設定も簡単に追加できる
  - 軽量であり、高い処理速度を提供
  - ミドルウェアとは
    - Webアプリケーションのリクエストとレスポンスの間で処理を追加するための中間の処理(例：ユーザー認証、CORS対応など)
- 単にデータベース操作をするだけであれば、データベース操作の実装だけでよいが、HTTP通信を実装する理由
  - ブラウザでページを表示するため
  - 他のシステムとの連携(フロントエンドやモバイルアプリからサーバーにアクセスできる)
  - ユーザーフレンドリーな操作(ブラウザを通じたフォームやボタン操作は直感的)
- Golangのinit関数について
  - パッケージ全体の初期設定
  - 外部リソースやデータベースへの接続
  - デフォルト設定の適用
- Redisとは


## メモ
- viewディレクトリ：HTMLファイルを格納
- buildディレクトリ：Dockerファイルを格納(アプリ用(Golang)とデータベース用)
- データベースのテーブルに格納されているかの確認
```
docker exec -it shop_map_db mysql -u root -p

USE shopmap_database;

SHOW TABLES;

SELECT * FROM users;
```

## エラーや悩んだところ
- コンテナ上のgolangからコンテナ上のMySQLへ接続できない->解決済
  - docker-compose.ymlファイルにて、DBのnetworksの指定の記述が漏れていた
- Riverpodの各Providerがどんなときに使うものかわかっていない

## 各参考サイト
### Frontend
- [【Flutter】NavigationBarを使って各画面を呼び出してみる](https://qiita.com/riku333/items/0e02e576e8dfa1878fb3) -> GoRouterを使用しているので併用不可
- [[続] go_routerでBottomNavigationBarの永続化に挑戦する(StatefulShellRoute)](https://zenn.dev/flutteruniv_dev/articles/stateful_shell_route)
- [FlutterアプリにGoogleマップを追加する](https://codelabs.developers.google.com/codelabs/google-maps-in-flutter?hl=ja#2)
- [【Flutter】Riverpodで使うProviderの種類をわかりやすくまとめてみた](https://qiita.com/yuu1111main/items/285109b3197e1499e0a0)

### Backend
- [docker-composeでgolangとMySQLを繋ぐ](https://zenn.dev/ajapa/articles/443c396a2c5dd1)
- [DockerコンテナでgolangをホットリロードするAirを導入](https://zenn.dev/ajapa/articles/bc399c7e4c0def)
- [Gorm(golang用ORマッパー)を使う](https://zenn.dev/ajapa/articles/aa9b59dd30c501)
- [golangフレームワークginを使ってみる](https://zenn.dev/ajapa/articles/6471ac0c612fda)
- [init関数のふしぎ #golang](https://qiita.com/tenntenn/items/7c70e3451ac783999b4f)