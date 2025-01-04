package controller

import (
	"github.com/gin-gonic/gin"
)

func GetRouter() *gin.Engine {
	// Ginルーター作成
	router := gin.Default()

	// Flutterから入力されたPOSTエンドポイントを設定
	// ログイン
	router.POST("/login", postLogin)

	// 新規登録
	router.POST("/login/signup", postSignup)

	// ログアウト
	router.POST("/logout", postLogout)

	// ガチャ場所の登録
	router.POST("/registeringlocation", postRegisteringLocation)

	// FlutterからリクエストされたGETエンドポイントを設定
	// セッション確認
	router.GET("/check-session", checkSession)

	// MySQLに保存されたマーカー取得
	router.GET("/get-marker", getMarker)

	return router
}
