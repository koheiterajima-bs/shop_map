package main

import (
	"github.com/koheiterajima-bs/shop_map/controller"
)

func main() {
	// ルーティング
	router := controller.GetRouter()
	router.Run(":8080")
	// router.Run("0.0.0.0:8080")
}
