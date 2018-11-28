function Export-Issue($backlogApiUrl, $projectKey, $apiKey) {

    # Backlogの課題関連APIルート
    $backlogProjApi = "${backlogApiUrl}/projects"
    $backlogIssueApi = "${backlogApiUrl}/issues"

    # プロジェクト情報取得
    function GetProject($baseUrl, $proj, $key) {
        $url = "${baseUrl}/${proj}?apiKey=${key}"
    
        # APIを叩いてプロジェクト情報を取得
        $res = Invoke-WebRequest "${url}"
        $con = [System.Text.Encoding]::Utf8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($res.Content))
    
        # JSONを配列に変換
        $project = ConvertFrom-Json $con
        return $project
    }

    # 課題一覧取得
    function GetIssues($baseUrl, $proj, $key) {

        $url = "${baseUrl}?apiKey=${key}&projectId[]=${proj}"

        # APIを叩いて課題一覧を取得
        $res = Invoke-WebRequest "${url}"
        $con = [System.Text.Encoding]::Utf8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($res.Content))

        # JSONを配列に変換
        $issues = ConvertFrom-Json $con
        return $issues
    }

    # 課題出力ディレクトリ作成
    function MakeIssueDir($issue, $proj) {
        $issueDir = $issue.summary
        $issueDir = "${proj}\issue\$($issue.id)-${issueDir}"
        # 課題ページ名でディレクトリを作成する
        New-Item $issueDir -ItemType Directory | Out-Null

        return $issueDir
    }

    # 課題本文ダウンロードする
    function DownloadIssue($baseUrl, $issue, $issueDir, $key) {

        [System.Console]::WriteLine($issue.summary)

        # 課題ページ情報のAPIは/api/v2/issues/{issueId}
        $issueUrl = "${baseUrl}/$($issue.id)?apiKey=${key}"
        $res = Invoke-WebRequest "${issueUrl}"
        $con = [System.Text.Encoding]::Utf8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($res.Content))
        $issuedata = ConvertFrom-Json $con

        $issueName = (Split-Path -Leaf $issueDir) + ".md"
        $jsonName = "origin-" + (Split-Path -Leaf $issueDir) + ".json"

        # ファイルを出力
        $issuedata.description | Out-File "${issueDir}\${issueName}" -Encoding UTF8
        $issuedata | ConvertTo-Json | Out-File "${issueDir}\${jsonName}" -Encoding UTF8
    }

    # 課題のコメント一覧を取得する
    function GetComments($baseUrl, $issue, $issueDir, $key) {

        $commentUrl = "${baseUrl}/$($issue.id)/comments?apiKey=${key}"
        $res = Invoke-WebRequest "${commentUrl}"
        $con = [System.Text.Encoding]::Utf8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($res.Content))
        $comments = ConvertFrom-Json $con

        return $comments
    }

    # コメントを出力する（課題の変更履歴などもコメントに含まれる）
    function OutputComment($comment, $issueDir) {
        $jsonName = "origin-$($comment.id).json"
        $jsonFile = "${issueDir}\${jsonName}"

        # 変更履歴を含むオリジナルのJSONファイルを出力
        $comment | ConvertTo-Json | Out-File $jsonFile -Encoding UTF8

        # コメントがついているもののみ情報を拾って
        if ($null -ne $comment.content) {
            $commentName = "comment-$($comment.id).txt"
            $commentFile = "${issueDir}\${commentName}"
            "ユーザー：$($comment.createdUser.name)" | Out-File $commentFile -Encoding UTF8 -Append
            "登録日時：$($comment.created)" | Out-File $commentFile -Encoding UTF8 -Append
            "更新日時：$($comment.updated)" | Out-File $commentFile -Encoding UTF8 -Append
            "更新フィールド：$($comment.changeLog.field)" | Out-File $commentFile -Encoding UTF8 -Append
            "変更前：$($comment.changeLog.originalValue)" | Out-File $commentFile -Encoding UTF8 -Append
            "変更後：$($comment.changeLog.newValue)" | Out-File $commentFile -Encoding UTF8 -Append
            "コメント：$($comment.content)" | Out-File $commentFile -Encoding UTF8 -Append
        }
    }

    # 添付ファイルダウンロード
    function DownloadAttachedFile($baseUrl, $issueId, $attachment, $issueDir, $key) {
        $attachemtApiUrl = "${baseUrl}/${issueId}/attachments/$($attachment.id)?apiKey=${key}"
        Invoke-WebRequest "${attachemtApiUrl}" -OutFile "${issueDir}\$($attachment.id)_$($attachment.name)"
    }

    #### 実行 ####

    [System.Console]::WriteLine("---- 課題エクスポート開始 ----")

    # プロジェクト情報取得
    $project = GetProject $backlogProjApi $projectKey $apiKey
    # 課題一覧取得
    $issueList = GetIssues $backlogIssueApi $project.id $apiKey
    # 課題をダウンロード
    foreach ($issue in $issueList) {
        $issueDir = MakeIssueDir $issue $project.projectKey

        DownloadIssue $backlogIssueApi $issue $issueDir $apiKey

        # コメント一覧を取得
        $commentList = GetComments $backlogIssueApi $issue $issueDir $apiKey
        # コメントをダウンロード
        foreach ($comment in $commentList) {
            OutputComment $comment $issueDir
        }
        # 添付ファイルをダウンロード
        foreach($attachment in $issue.attachments) {
            DownloadAttachedFile $backlogIssueApi $issue.id $attachment $issueDir $apiKey
        }

    }

    [System.Console]::WriteLine("---- 課題エクスポート終了 ----")

}