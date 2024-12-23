package controller

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/koheiterajima-bs/shop_map/model"
)

// セッションを確認するエンドポイント
func checkSession(c *gin.Context) {
	// クライアントから送信されたCookieを取得
	cookieKey := "LOGIN_USER_ID_KEY"
	sessionValue := model.GetSession(c, cookieKey)

	if sessionValue == nil {
		// セッションが無効
		c.JSON(http.StatusUnauthorized, gin.H{
			"message": "ログインが必要です",
		})
		return
	}

	// セッションが有効
	c.JSON(http.StatusOK, gin.H{
		"message": "ログイン済み",
		"user_id": sessionValue,
	})
}
