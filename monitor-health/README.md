# monitor-health

システムのリソース(CPU、メモリ、ストレージ)を監視し、指定した閾値を超えた場合に高負荷なプロセスを特定して表示するBashスクリプトである。

## 概要

- **CPU監視**: 閾値を超えた場合、CPU使用率の高い上位5プロセスを表示。

- **メモリ監視**: 閾値を超えた場合、メモリ使用率の高い上位5プロセスを表示。

- **ストレージ監視**: 閾値を超えた場合、ルートディレクトリ以下の容量が大きいディレクトリを表示。

- **堅牢性**: 数値バリデーションや必要なコマンド(ps, awk, dfなど)の存在チェックを実施。

- **マルチOS対応**: Ubuntu, Rocky Linux, Alpine Linuxで動作確認済み。

## 動作イメージ 
実行例
```bash
chmod 755 ./scripts/monitor_health.sh
./scripts/monitor_health.sh 70 70 70
```

### 出力例
```
---Health Check: 2026-03-30 21:00:00 ---
CPU usage exceeds threshold: 85.5% (Threshold: 70%)
USER       PID %CPU %MEM COMMAND
root      1234 45.0  2.1 yes
user      5678 20.1  1.5 python3
...
MEM usage: 45.2%
STG usage: 30%
```

## 使用方法

```bash
# デフォルト設定で実行(各閾値 80%)
./scripts/monitor_health.sh

# カスタム設定(CPU 50%, MEM 60%, STG 90%)
./scripts/monitor_health.sh 50 60 90
```

### パラメータ

|パラメータ|必須|デフォルト|説明|
|---|---|---|---|
|CPU_THR|NO|80|CPU使用率の閾値(%)|
|MEM_THR|NO|80|メモリ使用率の閾値(%)|
|STG_THR|NO|80|ストレージ使用率の閾値(%)|

## テスト

Docker Composeを使用して複数のOS(Ubuntu, Rocky Linux, Alpine)でテストできる。
```bash
# docker-compose.ymlからイメージをビルドする
docker compose build --no-cache

# ubuntu環境で実行する
docker compose run -d ubuntu-test /bin/bash -c "/app/tests/test_monitor_health.sh ; tail -f /dev/null"

# Rocky linux環境で実行する
docker compose run -d rockylinux-test /bin/bash -c "/app/tests/test_monitor_health.sh ; tail -f /dev/null"

# alpine環境で実行する
docker compose run -d alpine-test /bin/sh -c "/app/tests/test_monitor_health.sh ; tail -f /dev/null"

# 3環境で実行する
docker compose up -d

# コンテナのログを見る
docker logs [コンテナID]

# コンテナ内に入る
docker exec -it [コンテナID] bash

# コンテナを停止、削除する。関連するNWも削除する。
docker compose down --remove-orphans
```

## ファイル構成

```
monitor-health/
├── scripts/
│   └── monitor_health.sh          # メインスクリプト
├── tests/
│   ├── test_monitor_health.sh     # テストスクリプト
│   ├── status.log                 # テスト用ログ
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
実行には以下のコマンドが必要。
bash, ps, awk, df, free, top, tail, grep
※Alpineで実行する場合、procpsなどのパッケージが必要になる。