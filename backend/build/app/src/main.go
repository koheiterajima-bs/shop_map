package main

import (
	"github.com/koheiterajima-bs/shop_map/controller"
)

func main() {
	// ルーティング
	router := controller.GetRouter()
	router.Run(":8080")
}
