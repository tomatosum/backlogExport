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

`_auth.bat`を`auth.bat`にリネームし、

```bat
set API_KEY=xxxxxxxxxxxxxxxx
```

部分を実際のAPIキーに変更し以下のコマンドを実行

```bat
export.bat スペースID プロジェクトKey 出力ディレクトリ
```

## 実行結果

出力ディレクトリで指定したディレクトリに以下のように出力される

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
