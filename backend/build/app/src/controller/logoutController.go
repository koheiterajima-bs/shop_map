package controller

import (
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/koheiterajima-bs/shop_map/model"
)

func postLogout(c *gin.Context) {
	cookieKey := os.Getenv("LOGIN_USER_ID_KEY") // Cookieのキー名

	// ログアウト処理を実施
	model.DeleteSession(c, cookieKey)

	// ログアウト成功のレスポンス
	c.JSON(http.StatusOK, gin.H{"message": "ログアウトに成功しました"})
}
