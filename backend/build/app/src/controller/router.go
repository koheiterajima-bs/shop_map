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
	router.POST("/signup", postSignup)

	// GET:特定のページを見たいと要求するリクエスト
	// POST:ブラウザからデータをサーバーに送信するときに使う
	// // トップページ
	// router.GET("/", getTop)

	// // 新規登録ページ
	// router.GET("/signup", getSignup)
	// router.POST("/signup", postSignup)

	// // ログインページ
	// router.GET("/login", getLogin)
	// router.POST("/login", postLogin)

	return router
}
