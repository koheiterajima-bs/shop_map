// Redisに関する処理
package model

import (
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"io"

	"github.com/gin-gonic/gin"
	"github.com/go-redis/redis"
)

// Redis接続用のクライアント変数を宣言
var conn *redis.Client

func init() {
	// Redisサーバーへの接続を作成
	conn = redis.NewClient(&redis.Options{
		Addr:     "redis:6379",
		Password: "",
		DB:       0,
	})
}

// セッションを新規作成する関数
func NewSession(c *gin.Context, cookieKey, redisValue string) {
	// ランダムな文字列を生成
	b := make([]byte, 64)
	if _, err := io.ReadFull(rand.Reader, b); err != nil {
		panic("ランダムな文字作成時にエラーが発生しました")
	}

	// 生成したランダムデータをBase64形式に変換
	newRedisKey := base64.URLEncoding.EncodeToString(b)

	// Redisにセッションデータを保存(サーバー側)
	if err := conn.Set(newRedisKey, redisValue, 0).Err(); err != nil {
		panic("Session登録時にエラーが発生:" + err.Error())
	}
	// クライアントにCookieをセット(ブラウザ側)
	c.SetCookie(cookieKey, newRedisKey, 0, "/", "localhost", false, false)
}

// セッションデータを取得する関数
func GetSession(c *gin.Context, cookieKey string) interface{} {
	// CookieからRedisのキーを取得(クライアントから送られたCookieを取得)
	redisKey, _ := c.Cookie(cookieKey)

	// Redisからセッションデータを取得(クライアントから取得したCookieKeyを用い、サーバーから保存されている値を取得)
	redisValue, err := conn.Get(redisKey).Result()

	switch {
	case err == redis.Nil:
		fmt.Println("SessionKeyが登録されていません")
		return nil
	case err != nil:
		fmt.Println("Session取得時にエラー発生:" + err.Error())
		return nil
	}
	return redisValue
}

// セッションを削除する関数
func DeleteSession(c *gin.Context, cookieKey string) {
	// Redisのキーを削除(サーバーからデータを削除)
	redisId, _ := c.Cookie(cookieKey)
	conn.Del(redisId)

	// Cookieを削除(クライアント側)
	c.SetCookie(cookieKey, "", -1, "/", "localhost", false, false)
}
