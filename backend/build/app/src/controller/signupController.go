package controller

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

type SignupData struct {
	ID       string `json:"user_id" binding:"required"`
	Password string `json:"password" binding:"required"`
}

func postSignup(c *gin.Context) {
	var input SignupData

	// リクエストのデータをバインド
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 受信したデータをログに表示
	fmt.Printf("ID: %s, Password: %s\n", input.ID, input.Password)

	// レスポンスを返す
	c.JSON(http.StatusOK, gin.H{
		"message": "Data received successfully!",
		"data":    input,
	})
}
