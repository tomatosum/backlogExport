function Export-File($backlogApiUrl, $projectKey, $apiKey) {

    # Backlogの課題関連APIルート
    $backlogFileApi = "${backlogApiUrl}/projects/${projectKey}/files"

    # ファイル一覧を取得
    function GetFiles($baseUrl, $path, $key) {
        $url = "${baseUrl}/metadata${path}?apiKey=${key}"
        # APIを叩いてファイル一覧を取得
        $res = Invoke-WebRequest "${url}"
        $con = [System.Text.Encoding]::Utf8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($res.Content))

        # JSONを配列に変換
        $files = ConvertFrom-Json $con
        return $files
    }

    # 再帰的にディレクトリ階層以下のファイル一覧を取得
    function RepeatDir($baseUrl, $files, $proj, $key) {
        foreach ($file in $files) {
            if ($file.type -eq "file") {
                DownloadFile $baseUrl $file $proj $key
            } else {
                MakeFileDir $file $proj
                $dirFiles = GetFiles $baseUrl "$($file.dir)$($file.name)" $key
                RepeatDir $baseUrl $dirFiles $proj $key
            }
        }
    }

    # ファイルをダウンロード
    function DownloadFile($baseUrl, $file, $proj, $key) {
        $filePath = GetFilePath $file $proj
        $url = "${baseUrl}/$($file.id)?apiKey=${key}"
        [System.Console]::WriteLine("${filePath}")
        Invoke-WebRequest "${url}" -OutFile $filePath
    }

    # ファイル出力ディレクトリ作成
    function MakeFileDir($file, $proj) {
        $fileDir = GetFilePath $file $proj
        # ディレクトリを作成する
        New-Item $fileDir -ItemType Directory | Out-Null
        return $fileDir
    }

    # 出力先ファイルパスを取得
    function GetFilePath($file, $proj) {
        $fileDir = "$($file.dir)$($file.name)".Replace('/','\')
        $fileDir = "${proj}\file$($fileDir)"
        return $fileDir
    }

    #### 実行 ####

    [System.Console]::WriteLine("---- ファイルエクスポート開始 ----")

    # ファイルルート直下の一覧を取得
    $rootFiles = GetFiles $backlogFileApi "/" $apiKey
    # ディレクトリ以下を再帰的に取得
    RepeatDir $backlogFileApi $rootFiles $projectKey $apiKey

    [System.Console]::WriteLine("---- ファイルエクスポート終了 ----")

}
