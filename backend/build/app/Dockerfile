# ベースイメージ(alpineは軽量なLinux distribution)
FROM golang:1.23.0-alpine

# イメージ内に必要なソフトウェアをインストール
# apk: Alpine Linuxで使われるパッケージマネージャ
RUN apk update && apk add git


# コンテナ内での作業ディレクトリ
WORKDIR /go/src

# コンテナが起動した時に実行されるコマンドを指定
CMD ["go", "run", "main.go"]

