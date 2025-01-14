package controller

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/koheiterajima-bs/shop_map/model"
)

type RegisteringLocationData struct {
	Lat             float64  `json:"lat" binding:"required"`
	Lng             float64  `json:"lng" binding:"required"`
	ShopName        string   `json:"shop_name" binding:"required"`
	Genre           []string `json:"genre" binding:"required"`
	Unit            []string `json:"unit" binding:"required"`
	ExchangeMachine bool     `json:"exchange_machine" binding:"required"`
	AccountName     string   `json:"account_name" binding:"required"`
}

func postRegisteringLocation(c *gin.Context) {
	var input RegisteringLocationData

	// リクエストのデータをバインド
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 受信したデータをログに表示
	fmt.Printf("Lat: %.11f, Lng: %.11f, ShopName: %s, Genre: %s, Unit: %s, ExchangeMachine: %t, AccountName: %s\n", input.Lat, input.Lng, input.ShopName, input.Genre, input.Unit, input.ExchangeMachine, input.AccountName)

	// 場所の登録処理を実施
	location, err := model.RegisterLocation(input.Lat, input.Lng, input.ShopName, input.Genre, input.Unit, input.ExchangeMachine, input.AccountName)
	if err != nil {
		fmt.Println("ガチャ場所を登録できませんでした")
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// レスポンスを返す
	c.JSON(http.StatusOK, gin.H{
		"message":  "ガチャ場所の登録に成功しました！",
		"location": location,
	})
}
