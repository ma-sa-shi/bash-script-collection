# log-archiver

指定した日数を経過したログファイルを圧縮し、指定した日数を経過したアーカイブファイルを削除するBashスクリプトである。

## 概要

- **圧縮**: 指定日数（デフォルト30日）を過ぎた`.log`ファイルを`tar.gz`形式でアーカイブ。

- **削除**: 指定日数（デフォルト90日）を過ぎたアーカイブを削除。

- **堅牢性**: 権限チェックや数値バリデーションを実施し、誤操作を防止。

- **マルチOS対応**: Ubuntu, Rocky Linux, Alpine Linuxで動作確認済み。

## 動作イメージ 
実行例
```bash
chmod 755 ./scripts/archive_logs.sh
./scripts/archive_logs.sh /var/log/ 20 80 
```
### 実行前
```
./logs
├── app.log (今日)
├── system.log (10日前)
└── access.log (30日前) <-- アーカイブ対象

./backup/logs
├── logs_20260201.tar.gz (60日前)
└── logs_20251201.tar.gz (100日前) <-- 削除対象
```
### 実行後
```
./logs
├── app.log (保持)
└── system.log (保持)

./backup/logs
├── logs_20260201.tar.gz (保持)
├── access_20260328.tar.gz (新規作成)
※logs_20251201.tar.gzは削除される。
```

## 使用方法

```bash
# デフォルト設定でアーカイブ(30日以上経過したログをアーカイブ、90日以上経過したアーカイブを削除)
./scripts/archive_logs.sh ./logs

# カスタム設定(50日以上経過したログをアーカイブ、100日以上経過したアーカイブを削除)
./scripts/archive_logs.sh ./logs ./backup/logs 50 100
```
### パラメータ

|パラメータ|必須|デフォルト|説明|
|---|---|---|---|
|target_dir|YES|-|ログが格納されているディレクトリ|
|archive_dir|NO|./archive|圧縮ファイルの保存先|
|archive_days|NO|30|アーカイブ対象にする経過日数|
|delete_days|NO|90|アーカイブを削除する経過日数|

## テスト

Docker Composeを使用して複数のOS(Ubuntu, Rocky Linux, Alpine)でテストできる。
```bash
# docker-compose.ymlからイメージをビルドする
docker compose build --no-cache

# ubuntu環境で実行する
docker compose run -d ubuntu-test /bin/bash -c "/app/tests/test_archive_logs.sh ; tail -f /dev/null"

# rocky-linux環境で実行する
docker compose run -d rockylinux-test /bin/bash -c "/app/tests/test_archive_logs.sh ; tail -f /dev/null"

# alpine環境で実行する
docker compose run -d alpine-test /bin/sh -c "/app/tests/test_archive_logs.sh ; tail -f /dev/null"

# 3環境で実行する
docker compose up -d

# コンテナのログを見る
docker logs [コンテナID]

# コンテナ内に入る
docker exec -it [コンテナID] bash

# コンテナ内のディレクトリ構造を確認する
tree

# コンテナを停止、削除する。関連するNWも削除する。
docker compose down --remove-orphans
```

## ファイル構成

```
log-archiver/
├── scripts/
│   └── archive_logs.sh          # メインスクリプト
├── tests/
│   ├── test_archive_logs.sh     # テストスクリプト
│   ├── alpine/
│   │   └── alpine.Dockerfile    
│   ├── rockylinux/
│   │   └── rockylinux.Dockerfile 
│   └── ubuntu/
│       └── ubuntu.Dockerfile    
├── docker-compose.yml           
└── README.md                    
```

## 注意事項
実行には bash, find, tar, gzipが必要である。