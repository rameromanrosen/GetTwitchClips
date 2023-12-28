### 変数定義
# カレントディレクトリ
$dir = Split-Path $MyInvocation.MyCommand.path
# スクリプト実行日取得
$nowtime = (get-date).tostring("yyyyMMdd")
# Googleスプレッドシート用tsvファイル（ハイパーリンク、視聴回数、カテゴリ、動画時間、作成日時、URL）
$global:outputcsv = $dir + "\..\tsv\clips_" + $nowtime + ".tsv"
# アットウィキ用txtファイル（ハイパーリンク、視聴回数、カテゴリ、動画時間、作成日時、URL）
$global:outputwiki = $dir + "\..\wiki\clips_" + $nowtime + ".txt"
# 保管用tsvファイル（全量）
$global:logfile = $dir + "\..\log\GetClips_" + $nowtime + ".tsv"
# ループ開始用cursorValue定義
$global:cursorValue = 99

### Twitch配信者ID
$global:broadcasterId = "880929630"

### メイン処理
# 文字コード指定
[System.Console]::OutputEncoding=[System.Text.Encoding]::GetEncoding('utf-8')

# 同名アウトプットファイル削除
If(Test-Path $global:outputcsv){ Remove-Item $global:outputcsv -Force }
If(Test-Path $global:outputwiki){ Remove-Item $global:outputwiki -Force }
If(Test-Path $global:logfile){ Remove-Item $global:logfile -Force }

# cursorValueが空になるまで処理をループする
While($global:cursorValue -ne $null){
    Switch($global:cursorValue){
        # クリップ情報取得（初回：オプション「after」なし） 
        99 {
            $global:jsondatas = twitch api get /clips -q broadcaster_id=$global:broadcasterId -q first=100 |ConvertFrom-Json
        }
        # クリップ情報取得（2回目以降：オプション「after」あり）
        default {
            $global:jsondatas = twitch api get /clips -q broadcaster_id=$global:broadcasterId -q first=100 -q after=$global:cursorValue |ConvertFrom-Json
        }
    }
    # cursorValue取得
    $global:cursorValue = $global:jsondatas.pagination.cursor
    # jsonデータを1件ずつ読み込んでアウトプットファイルへ転記
    foreach($jsondata in $global:jsondatas.data){
        # ゲームID取得
        $gameId = $jsondata.game_id
        # ゲーム情報取得
        $gamejson = twitch api get /games -q id=$gameId |ConvertFrom-Json
        # クリップタイトルに含まれている改行コードを削除
        $titlemod = ($jsondata.title).Replace("`n","")
        # jsonの作成日時データをDateTime型で取得
        $datemod = [datetime]($jsondata.created_at)
        # Googleスプレッドシート用tsvファイルへ転記
        "=HYPERLINK(`"" + $jsondata.url + "`",`"" + ($titlemod).replace("`"","`"`"") + "`")" + "`t" + $jsondata.view_count + "`t" + $gamejson.data.name + "`t" + $jsondata.duration + "`t" + $datemod.ToString("yyyy/MM/dd HH:mm:ss") + "`t" + $jsondata.url >> $global:outputcsv
        # アットウィキ用txtファイルへ転記
        "|[[" + $titlemod + ">>" + $jsondata.url + "]]|" + $jsondata.view_count + "|" + $gamejson.data.name + "|" + $jsondata.duration + "|" + $datemod.ToString("yyyy/MM/dd HH:mm:ss") + "|" >> $global:outputwiki
        # 保管用tsvファイルへ転記
        $jsondata.broadcaster_id + "`t" + $jsondata.broadcaster_name + "`t" + $jsondata.created_at + "`t" + $jsondata.creator_id + "`t" + $jsondata.creator_name + "`t" + $jsondata.duration + "`t" + $jsondata.embed_url + "`t" + $jsondata.game_id + "`t" + $jsondata.id + "`t" + $jsondata.is_featured + "`t" + $jsondata.language + "`t" + $jsondata.thumbnail_url + "`t" + $titlemod + "`t" + $jsondata.url + "`t" + $jsondata.video_id + "`t" + $jsondata.view_count + "`t" + $jsondata.vod_offset >> $global:logfile
    }
}