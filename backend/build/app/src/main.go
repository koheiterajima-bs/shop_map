package main

import (
	"github.com/koheiterajima-bs/shop_map/model"
)

func main() {
	// connectDBを呼び出してMySQLデータベースに接続
	db := model.ConnectDB()
	// プログラム終了時にデータベース接続を閉じる
	defer db.Close()
	model.ReadAll(db)
}
