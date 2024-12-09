package model

type User struct {
	ID       int
	UserID   string
	Password string
}

// MySQLのテーブル初期化
func InitTable() {
	// データベースのテーブル作成
	db.Set("gorm:table_options", "ENGINE = InnoDB").AutoMigrate(User{})
}

// func ReadAll(db *sql.DB) {
// 	// 取得データを格納するスライス
// 	var users []User
// 	// データベースに対してSQLクエリを実行する
// 	rows, err := db.Query("SELECT * FROM users;")
// 	if err != nil {
// 		panic(err)
// 	}
// 	// クエリ結果の読み取り
// 	for rows.Next() {
// 		// User型の変数を作成
// 		user := User{}
// 		// データのスキャン(クエリ結果から一行分のデータをuserに読み取る)
// 		err = rows.Scan(&user.ID, &user.UserID, &user.Password)
// 		if err != nil {
// 			panic(err)
// 		}
// 		users = append(users, user)
// 	}
// 	// クエリ結果を閉じる
// 	rows.Close()

// 	// 結果を出力
// 	fmt.Println(users)
// }
