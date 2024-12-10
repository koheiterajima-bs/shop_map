package controller

import (
	"fmt"
	"net/http"

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
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 受信したデータをログに表示
	fmt.Printf("ID: %s, Password: %s\n", input.ID, input.Password)

	// ログイン処理を実施
	user, err := model.Login(input.ID, input.Password)
	if err != nil {
		c.Redirect(301, "/login")
		return
	}

	// 出力(後で消す？)
	fmt.Println(user)
	fmt.Println("ログインできました！！")

	// レスポンスを返す
	c.JSON(http.StatusOK, gin.H{
		"message": "Data received successfully!",
		"data":    input,
	})
}
