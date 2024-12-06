// MySQL(DB)に直接関与する処理
package model

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

// MySQLに接続するための関数
func open(path string, count uint) *sql.DB {
	db, err := sql.Open("mysql", path)
	if err != nil {
		// log.Fatal("open error:", err)
		log.Println("open error:", err) // エラー詳細を表示
		log.Fatal("DB接続に失敗しました。")
	}

	// 接続のリトライ機能
	if err = db.Ping(); err != nil {
		// 接続に失敗した場合、2秒待機してもう一度接続を試みる
		time.Sleep(time.Second * 2)
		count--
		fmt.Printf("retry... count:%v\n", count)
		// 再帰的にopen関数を呼び出してリトライする
		return open(path, count)
	}

	fmt.Println("db connected!!")
	return db
}

// 接続文字列(Data Source Name)を作成し、open関数を呼び出してMySQLに接続
func ConnectDB() *sql.DB {
	// 接続文字列(os.Getenvは環境変数を取得)
	var path string = fmt.Sprintf("%s:%s@tcp(db:3306)/%s?charset=utf8&parseTime=true",
		os.Getenv("MYSQL_USER"), os.Getenv("MYSQL_PASSWORD"), os.Getenv("MYSQL_DATABASE"))

	return open(path, 100)
}
