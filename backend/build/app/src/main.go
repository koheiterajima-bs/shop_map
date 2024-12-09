package main

import (
	"github.com/koheiterajima-bs/shop_map/backend/build/app/src/controller"
)

func main() {
	// ルーティング
	router := controller.GetRouter()
	router.Run(":8080")

	// // MySQLの初期化と接続
	// db := model.Init()
	// // プログラム終了時にデータベース接続を閉じる
	// sqlDB, _ := db.DB()
	// defer sqlDB.Close()

	// // テーブルの初期化
	// model.InitTable()
}
