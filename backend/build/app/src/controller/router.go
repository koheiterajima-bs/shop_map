package controller

import (
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func GetRouter() *gin.Engine {
	// Ginルーター作成
	router := gin.Default()

	// CORS設定をミドルウェアとして追加
	router.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"http://10.0.2.2:8080", "http://localhost:8080"}, // 許可するオリジン
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE"},                  // 許可するHTTPメソッド
		AllowHeaders:     []string{"Content-Type", "Authorization"},                 // 許可するヘッダー
		AllowCredentials: true,                                                      // Cookieを許可
	}))

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

	// MySQLに保存されたユーザー情報取得
	router.GET("/get-user", getUser)

	return router
}
