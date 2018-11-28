Param($spaceId, $projectKey, $apiKey, $outputDir)

# TLS1.2に切り替える
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

# 依存ファイルの読み込み
. ".\exportWiki.ps1"
. ".\exportIssue.ps1"
. ".\exportFile.ps1"

# BacklogAPIのURL
$BACKLOG_API = "https://${spaceId}.backlog.jp/api/v2"

# バックアップの出力ディレクトリを作成
if (!(Test-Path $outputDir)) {
    New-Item $outputDir -ItemType Directory | Out-Null
}

# 現在のディレクトリを取得
$currentDir = [System.IO.Directory]::GetCurrentDirectory()

# 出力ディレクトリに移動
Set-Location $outputDir

Export-Wiki $BACKLOG_API $projectKey $apiKey
Export-Issue $BACKLOG_API $projectKey $apiKey
Export-File $BACKLOG_API $projectKey $apiKey

# 出力ディレクトリから元のディレクトリに戻る
Set-Location $currentDir
