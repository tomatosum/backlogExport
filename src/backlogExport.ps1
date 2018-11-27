# TLS1.2に切り替える
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

# 依存ファイルの読み込み
. ".\exportWiki.ps1"
. ".\exportIssue.ps1"
. ".\exportFile.ps1"

# BacklogのAPI
$BACKLOG_API = "https://spaceId.backlog.jp/api/v2"
# バックアップしたいプロジェクトキー
$PROJECT_KEY = "projectId"
# BacklogのAPIキー
$API_KEY = "backlogApiKey"
# バックアップの出力先
$OUTPUT_DIR = "output"

# バックアップの出力ディレクトリを作成
if (!(Test-Path $OUTPUT_DIR)) {
    New-Item $OUTPUT_DIR -ItemType Directory | Out-Null
}
# 出力ディレクトリに移動
Set-Location .\output

Export-Wiki $BACKLOG_API $PROJECT_KEY $API_KEY
Export-Issue $BACKLOG_API $PROJECT_KEY $API_KEY
Export-File $BACKLOG_API $PROJECT_KEY $API_KEY

# 出力ディレクトリから元のディレクトリに戻る
Set-Location ..\
