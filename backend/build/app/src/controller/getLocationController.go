package controller

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/koheiterajima-bs/shop_map/model"
)

// マーカー取得を行うエンドポイント
func getMarker(c *gin.Context) {
	// 場所の取得処理を実施
	location, err := model.GetAllLocations()
	if err != nil {
		fmt.Println("ガチャ場所を取得できませんでした")
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// レスポンスを返す
	c.JSON(http.StatusOK, gin.H{
		"message":  "ガチャ場所の取得に成功しました！",
		"location": location,
	})
}
