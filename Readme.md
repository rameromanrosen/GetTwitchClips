# 1. 概要
- 指定したTwitch配信者のクリップ一覧を取得するPowershellスクリプトです
- 全期間のクリップを再生回数の多い順に取得します
- クリップ数が多い場合、実行時間が結構必要になります
- Windows10以降のOSでの実行を想定しています

# 2. 事前準備
- Twitch CLIのインストール
- Twitch Developersへアプリの登録
- Twitch CLIの初期設定
- Twitch配信者IDの取得
- GetTwitchClips.ps1のカスタマイズ

## 2.1. Twitch CLIのインストール
- [こちら](https://dev.twitch.tv/docs/cli/)を参考にインストールしてください
- 参考までに2023/12/29時点の手順を以下に示します
- Powershellで実行してください

```powershell
# Scoopインストール（コマンドラインインストーラ）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
# Twitch CLIインストール
scoop bucket add twitch https://github.com/twitchdev/scoop-bucket.git
scoop install twitch-cli
```

## 2.2. Twitch Developersへアプリの登録
- [こちら](https://dev.twitch.tv/docs/authentication/register-app/)を参考にインストールしてください
- ここで取得できる「Client ID」と「Client Secret」を、Twitch CLIの設定で使用します

## 2.3. Twitch CLIの初期設定
- Powershellで以下コマンドを実行します
- 「Client ID」と「Client Secret」を聞かれるので、それぞれ入力します
```powershell
PS C:\Users\owner> twitch configure
Client ID: t214nt...
Client Secret: hyss6ng...
Updated configuration.
PS C:\Users\owner> 
```

## 2.4. Twitch配信者IDの取得
- クリップを取得したいTwitch配信者のIDを取得します
- 下記のようにloginオプションにユーザ名を指定してください
```powershell
PS C:\Users\owner> twitch api get /users -q login=sunao_desuu
{
  "data": [
    {
      "broadcaster_type": "partner",
      "created_at": "2023-02-11T04:38:01Z",
      "description": "Ruskちゃんを使用させていただいてVtuberの時もあります（作者：こまど  様　Twitter:@komado_booth）金 曜9時からみんなでウォチパしてます！バーチャルと創作が好きです！",
      "display_name": "sunao_desuu",
      "id": "880929630",
      "login": "sunao_desuu",
      "offline_image_url": "",
      "profile_image_url": "https://static-cdn.jtvnw.net/jtv_user_pictures/fafe96ac-2a95-4858-ab8c-139e635d96eb-profile_image-300x300.png",
      "type": "",
      "view_count": 0
    }
  ]
}
PS C:\Users\owner>
```

## GetTwitchClips.ps1のカスタマイズ（配信者IDの設定）
- PS1フォルダ内の「GetTwitchClips.ps1」を編集します
- 16行目の$global:broadcasterIdを、先ほど取得したIDに書き換えてください
```powershell
$global:broadcasterId = "880929630"
```

## GetTwitchClips.ps1のカスタマイズ（アウトプットファイルの設定）
- PS1フォルダ内の「GetTwitchClips.ps1」を編集します
- アウトプットファイルは3つあるので、不要なものは削除してください
  - Googleスプレッドシート用tsvファイル（$global:outputcsv）
    - Twitch CLIの取得結果から必要な要素のみ抜き出して加工しています（ハイパーリンク、視聴回数、カテゴリ、動画時間、作成日時、URL）
    - Googleスプレッドシートに転記すると以下のような感じになります
    - ![image](https://github.com/rameromanrosen/GetTwitchClips/assets/71089552/9576a98f-0142-4e9f-945f-cd2413900364)
  - アットウィキ用txtファイル（$global:outputwiki）
    - Twitch CLIの取得結果から必要な要素のみ抜き出して加工しています（ハイパーリンク、視聴回数、カテゴリ、動画時間、作成日時、URL）
    - アットウィキに転記すると以下のような感じになります
    - ![image-1](https://github.com/rameromanrosen/GetTwitchClips/assets/71089552/3aebbdaa-2245-4f09-842f-2c41321b3106)
  - 保管用tsvファイル（$global:logfile）
    - Twitch CLIの結果を全量転記したものです

# 実行方法
- GetTwitchClips.batを実行します