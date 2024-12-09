// MySQL(DB)に直接関与する処理
package model

import (
	"fmt"
	"os"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var db *gorm.DB

// MySQL初期化(Gormを用いることで、.sqlファイルに初期設定を記述する必要がなくなる)
func init() {
	// .envファイルから読み込み
	user := os.Getenv("MYSQL_USER")
	password := os.Getenv("MYSQL_PASSWORD")
	db_name := os.Getenv("MYSQL_DATABASE")
	// 接続文字列
	var path string = fmt.Sprintf("%s:%s@tcp(db:3306)/%s?charset=utf8&parseTime=true", user, password, db_name)
	// データベース接続の定義(MySQL用のgorm.Dialectorを作成)
	dialector := mysql.Open(path)
	var err error
	// Gormがdialectorを使ってデータベースに接続する
	if db, err = gorm.Open(dialector); err != nil {
		connect(dialector, 100)
	}
	fmt.Println("db connected!!")
}

// エラーが発生し続ける限り再試行を行う
func connect(dialector gorm.Dialector, count uint) {
	var err error
	if db, err = gorm.Open(dialector); err != nil {
		if count > 1 {
			time.Sleep(time.Second * 2)
			count--
			fmt.Printf("retry... count:%v\n", count)
			connect(dialector, count)
			return
		}
		panic(err.Error())
	}
}
