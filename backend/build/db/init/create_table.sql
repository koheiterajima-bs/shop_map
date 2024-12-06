CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    userid VARCHAR(50),
    password VARCHAR(50)
);

-- テスト用データ
INSERT INTO users (userid, password) VALUES ('hogeuser01', 'hogehuga');
INSERT INTO users (userid, password) VALUES ('hogeuser02', 'hogehuga');
INSERT INTO users (userid, password) VALUES ('hogeuser03', 'hogehuga');