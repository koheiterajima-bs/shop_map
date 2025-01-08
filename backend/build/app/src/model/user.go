package model

import (
	"errors"

	"github.com/koheiterajima-bs/shop_map/crypto"
	"gorm.io/gorm"
)

type User struct {
	// gorm.Model:Gormが提供する基本モデルで、ID,CreatedAt,UpdatedAt,DeletedAtといったフィールドが自動的に追加される
	gorm.Model
	UserID   string
	Password string
}

// AutoMigrate:データベースにテーブルを作成・更新する
func init() {
	db.Set("gorm:table_options", "ENGINE = InnoDB").AutoMigrate(User{})
}

// ユーザーがログイン状態かどうかを判定
func (u *User) LoggedIn() bool {
	return u.ID != 0
}

// 新規登録の処理
func Signup(userId, password string) (*User, error) {
	// ユーザー名が既に存在するかどうかチェック
	user := User{}
	// 最初に一致したレコードを取得
	db.Where("user_id = ?", userId).First(&user)
	if user.ID != 0 {
		err := errors.New("同一名のUserIdが既に登録されています。")
		return nil, err
	}

	// パスワードの暗号化
	encryptPw, err := crypto.PasswordEncrypt(password)
	if err != nil {
		return nil, err
	}

	// 新規ユーザーを作成
	user = User{UserID: userId, Password: encryptPw}
	db.Create(&user)
	return &user, nil
}

// ログインの処理
func Login(userId, password string) (*User, error) {
	// ユーザーIDで検索
	user := User{}
	// 最初に一致したレコードを取得
	db.Where("user_id = ?", userId).First(&user)
	if user.ID == 0 {
		err := errors.New("UserIdが一致するユーザーが存在しません。")
		return nil, err
	}

	// パスワードの照合
	err := crypto.CompareHashAndPassword(user.Password, password)
	if err != nil {
		return nil, err
	}

	// 一致した場合、該当ユーザーを返す
	return &user, nil
}

// ユーザー情報取得の処理
func GetAllUsersInformation() ([]User, error) {
	var users []User
	if err := db.Find(&users).Error; err != nil {
		return nil, err
	}
	return users, nil
}
