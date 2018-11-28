# backlogExport

Backlogからプロジェクトをエクスポートする

:warning: エクスポートするだけでインポートはできない

## 対象

- Wiki
    - 添付ファイル含む
- 課題
    - 添付ファイル含む
    - コメント含む
- ファイル

## 使い方

:warning: 各ファイルがSJISになっていることを確認！

exportBacklog.ps1

```
# BacklogのAPI
$BACKLOG_API = "https://spaceId.backlog.jp/api/v2"
# バックアップしたいプロジェクトキー
$PROJECT_KEY = "projectId"
# BacklogのAPIキー
$API_KEY = "backlogApiKey"
# バックアップの出力先
$OUTPUT_DIR = "output"
```

あたりをいい感じに調整し、export.batを実行する

## 実行結果

`$OUTPUT_DIR`で指定したディレクトリに以下のように出力される

- Wiki：`PROJECT_KEY\wiki`
- 課題：`PROJECT_KEY\issue`
- ファイル：`PROJECT_KEY\file`

### 課題

課題ごとに1フォルダ作成され、

- `課題ID-課題タイトル.md`として課題本文
- `origin-課題ID-課題タイトル.json`として課題取得時のjson
- `comment-コメントID.txt`としてコメント本文のあるコメント
- `origin-コメントID.json`としてコメント取得時のjson
- `添付ファイルID_添付ファイル名`として添付ファイル

が保存される

### Wiki

ページごとに1フォルダ作成され、

- `ページタイトル.md`としてWiki本文
- `origin-ページ本文.json`としてWiki取得時のjson
- `添付ファイルID_添付ファイル名`として添付ファイル

が保存される
