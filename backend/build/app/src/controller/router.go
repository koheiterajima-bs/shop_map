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

	// FlutterからリクエストされたGETエンドポイントを設定
	router.GET("/check-session", checkSession)

	return router
}
