package model

import (
	"encoding/json"
	"errors"

	"gorm.io/gorm"
)

type Location struct {
	gorm.Model
	Lat             float64 `gorm:"not null"`
	Lng             float64 `gorm:"not null"`
	ShopName        string  `gorm:"not null"`
	Genre           string  `gorm:"type:json"` // JSONとして保存
	Unit            string  `gorm:"type:json"` // JSONとして保存
	ExchangeMachine bool    `gorm:"not null"`
	AccountName     string  `gorm:"not null"`
}

// AutoMigrate:データベースにテーブルを作成・更新する
func init() {
	db.Set("gorm:table_options", "ENGINE = InnoDB").AutoMigrate(Location{})
}

// 場所の登録の処理
func RegisterLocation(lat, lng float64, shopName string, genre, unit []string, exchangeMachine bool, accountName string) (*Location, error) {
	// ガチャ場所が既に存在するかどうかチェック
	var existingLocation Location
	if err := db.Where("lat = ? AND lng = ?", lat, lng).First(&existingLocation).Error; err != nil {
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, err // エラーが発生した場合は終了
		}
	}

	// 場所が既に存在していた場合
	if existingLocation.ID != 0 {
		return nil, errors.New("この経度・緯度の場所は既に存在します")
	}

	// 新しい場所を登録
	location := &Location{
		Lat:             lat,
		Lng:             lng,
		ShopName:        shopName,
		Genre:           toJSONString(genre), // JSON形式に変換
		Unit:            toJSONString(unit),  // JSON形式に変換
		ExchangeMachine: exchangeMachine,
		AccountName:     accountName,
	}

	// ガチャ場所を登録
	if err := db.Create(location).Error; err != nil {
		return nil, err
	}

	return location, nil
}

// toJSONString:スライスをJSON文字列に変換
func toJSONString(data []string) string {
	jsonData, _ := json.Marshal(data)
	return string(jsonData)
}

// 場所の取得の処理
func GetAllLocations() ([]Location, error) {
	var locations []Location
	if err := db.Find(&locations).Error; err != nil {
		return nil, err
	}
	return locations, nil
}

// アカウント名と一致した投稿のみを取得
func GetLocations(accountName string) ([]Location, error) {
	var locations []Location
	if err := db.Where("accountName = ?", accountName).Error; err != nil {
		return nil, err
	}
	return locations, nil
}
