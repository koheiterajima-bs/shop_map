package controller

import (
	"github.com/gin-contrib/sessions"
	"github.com/gin-contrib/sessions/cookie"
	"github.com/gin-gonic/gin"
)

// var LoginInfo SessionInfo

func GetRouter() *gin.Engine {
	// Ginルーター作成
	router := gin.Default()

	// Flutterから入力されたPOSTエンドポイントを設定
	// ログイン
	router.POST("/login", postLogin)

	// 新規登録
	router.POST("/login/signup", postSignup)

	// セッションの設定
	store := cookie.NewStore([]byte("secret"))
	router.Use(sessions.Sessions("mysession", store))

	return router
}

// セッションチェック
// func sessionCheck() gin.HandlerFunc {
// 	return func(c *gin.Context) {
// 		session := sessions.Default(c)
// 		LoginInfo.UserId = session.Get("UserId")

// 		// セッションがない場合、ログインフォームを出す
// 		if LoginInfo.UserId == nil {
// 			log.Println("ログインしていません")

// 		}
// 	}
// }
