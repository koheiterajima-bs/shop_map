package controller

import (
	"fmt"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/koheiterajima-bs/shop_map/model"
)

type LoginData struct {
	ID       string `json:"user_id" binding:"required"`
	Password string `json:"password" binding:"required"`
}

func postLogin(c *gin.Context) {
	var input LoginData

	// リクエストのデータをバインド
	// Flutterのフォームから送信されたリクエストボディー(JSON形式)を構造体にバインド
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 受信したデータをログに表示
	fmt.Printf("ID: %s, Password: %s\n", input.ID, input.Password)

	// ログイン処理を実施
	user, err := model.Login(input.ID, input.Password)
	if err != nil {
		fmt.Println("ログインできませんでした")
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 出力(後で消す？)
	fmt.Println(user)
	fmt.Println("ログインできました！！")

	// Redisにセッションを登録し、Cookieをセット
	cookieKey := os.Getenv("LOGIN_USER_ID_KEY") // Cookieのキー名
	fmt.Println(cookieKey)
	model.NewSession(c, cookieKey, input.ID) // input.IDをRedisに保存

	// レスポンスを返す
	c.JSON(http.StatusOK, gin.H{
		"message": "ログインに成功しました!",
		"user":    user,
	})
}
