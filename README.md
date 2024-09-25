# ラズパイ監視カメラ
## 開発環境
- Device: Raspberry Pi 4 Model B
- OS: 11.9
- Kernel: 6.1.21-v8+
- Raspberry Pi Image: v1.8.5

## 環境構築手順
- SSH接続設定（公開鍵認証）
```
$ mkdir .ssh
$ touch .ssh/authorized_keys
$ nano .ssh/authorized_keys

// 自身の公開鍵（.pub）の中身をコピペ

$ sudo apt update
$ sudo reboot

// 再起動後，再度SSH接続
```

- MJPG-Streamerのインストール
```
// 各種パッケージのインストール
$ sudo apt install -y git cmake libjpeg-dev
$ cd ~/
$ git clone https://github.com/neuralassembly/mjpg-streamer.git
$ cd mjpg-streamer/mjpg-streamer-experimental
$ make
$ sudo make install

// レガシーカメラモードをオンに設定
$ sudo raspi-config nonint do_legacy 0
$ sudo reboot

// 再起動後，再度SSH接続
```

- USBカメラ起動用のシェルスクリプト（start.sh）を作成
```
$ cd ~
$ touch start.sh
$ chmod 755 start.sh
$ nano start.sh

// 以下をコピペ
#!/bin/sh

PORT="8080"
WINDOWSIZE="640x480"
FRAMERATE="30"
export LD_LIBRARY_PATH=/usr/local/lib
mjpg_streamer -i "input_uvc.so -f $FRAMERATE -r $WINDOWSIZE -d /dev/video0 -y -n" \ -o "output_http.so -w /usr/local/share/mjpg-streamer/www -p $PORT"

export LD_LIBRARY_PATH="$(pwd)"
./mjpg_streamer -i "./input_uvc.so" -o "./output_http.so -w ./www"

// 保存して終了
```

- 動作確認
```
// カメラ起動
$ ./start.sh

https://{ホスト名}:8080?action=stream
```
配信リンクにアクセスして映像が表示されていれば完了

- ラズパイ起動時の自動ストリーミング設定
```
$ cd /etc/systemd/system
$ sudo touch mjpg-streamer.service
$ sudo nano mjpg-streamer.service

// 以下をコピペ
[Unit]
Description=MJPG-Streamer Service
After=network-online.target

[Service]
Type=simple
KillMode=process
Restart=always
ExecStart=/home/{ユーザー名}/start.sh

[Install]
WantedBy=multi-user.target

$ sudo systemctl daemon-reload
$ sudo systemctl start mjpg-streamer.service
$ sudo systemctl enable mjpg-streamer.service

// 再起動して確認
$ sudo reboot
```