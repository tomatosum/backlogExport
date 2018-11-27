function Export-Wiki($backlogApiUrl, $projectKey, $apiKey) {

    # BacklogのWiki関連APIルート
    $backlogWikiApi = "${backlogApiUrl}/wikis"

    # wiki一覧を取得
    function GetWikiList($baseUrl, $proj, $key) {
        $url = "${baseUrl}?apiKey=${key}&projectIdOrKey=${proj}"

        # APIを叩いてwiki一覧を取得
        $res = Invoke-WebRequest "${url}"
        $con = [System.Text.Encoding]::Utf8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($res.Content))

        # JSONを配列に変換
        $wikis = ConvertFrom-Json $con
        return $wikis
    }

    # Wiki出力ディレクトリ作成
    function MakeWikiDir($wiki, $proj) {
        $wikiDir = $wiki.name.Replace('/','\')
        $wikiDir = "${proj}\wiki\${wikiDir}"
        # Wikiページ名(階層含む)でディレクトリを作成する
        New-Item $wikiDir -ItemType Directory | Out-Null

        return $wikiDir
    }
    # Wiki本文ダウンロードする
    function DownloadWiki($baseUrl, $wiki, $wikiDir, $key) {

        [System.Console]::WriteLine($wiki.name)

        # ダウンロード
        $wikiUrl = "${baseUrl}/$($wiki.id)?apiKey=${key}"
        $res = Invoke-WebRequest "${wikiUrl}"
        $con = [System.Text.Encoding]::Utf8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($res.Content))
        $wikidata = ConvertFrom-Json $con

        # ファイル名を作成
        $wikiName = (Split-Path -Leaf $wikiDir) + ".md"
        $jsonName = "origin-" + (Split-Path -Leaf $wikiDir) + ".json"

        # ファイルを出力
        $wikidata.content | Out-File "${wikiDir}\${wikiName}" -Encoding UTF8
        $wikidata | ConvertTo-Json | Out-File "${wikiDir}\${jsonName}" -Encoding UTF8
    }

    # 添付ファイルダウンロード
    function DownloadAttachedFile($baseUrl, $wikiId, $attachment, $dir, $key) {
        $attachemtApiUrl = "${baseUrl}/${wikiId}/attachments/$($attachment.id)?apiKey=${key}"
        Invoke-WebRequest "${attachemtApiUrl}" -OutFile "${dir}\$($attachment.id)_$($attachment.name)"
    }

    #### 実行 ####

    [System.Console]::WriteLine("---- Wikiエクスポート開始 ----")

    # wiki一覧を取得
    $wikiList = GetWikiList $backlogWikiApi $projectKey $apiKey
    # wikiをダウンロード
    foreach ($wiki in $wikiList) {
        # 出力ディレクトリ作成
        $dir = MakeWikiDir $wiki $projectKey
        # wikiページをダウンロード
        DownloadWiki $backlogWikiApi $wiki $dir $apiKey
        # 添付ファイルをダウンロード
        foreach($attachment in $wiki.attachments) {
            DownloadAttachedFile $backlogWikiApi $wiki.id $attachment $dir $apiKey
        }
    }

    [System.Console]::WriteLine("---- Wikiエクスポート終了 ----")

}
