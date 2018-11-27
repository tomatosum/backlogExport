function Export-File($backlogApiUrl, $projectKey, $apiKey) {

    # Backlog�̉ۑ�֘AAPI���[�g
    $backlogFileApi = "${backlogApiUrl}/projects/${projectKey}/files"

    # �t�@�C���ꗗ���擾
    function GetFiles($baseUrl, $path, $key) {
        $url = "${baseUrl}/metadata${path}?apiKey=${key}"
        # API��@���ăt�@�C���ꗗ���擾
        $res = Invoke-WebRequest "${url}"
        $con = [System.Text.Encoding]::Utf8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($res.Content))

        # JSON��z��ɕϊ�
        $files = ConvertFrom-Json $con
        return $files
    }

    # �ċA�I�Ƀf�B���N�g���K�w�ȉ��̃t�@�C���ꗗ���擾
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

    # �t�@�C�����_�E�����[�h
    function DownloadFile($baseUrl, $file, $proj, $key) {
        $filePath = GetFilePath $file $proj
        $url = "${baseUrl}/$($file.id)?apiKey=${key}"
        [System.Console]::WriteLine("${filePath}")
        Invoke-WebRequest "${url}" -OutFile $filePath
    }

    # �t�@�C���o�̓f�B���N�g���쐬
    function MakeFileDir($file, $proj) {
        $fileDir = GetFilePath $file $proj
        # �f�B���N�g�����쐬����
        New-Item $fileDir -ItemType Directory | Out-Null
        return $fileDir
    }

    # �o�͐�t�@�C���p�X���擾
    function GetFilePath($file, $proj) {
        $fileDir = "$($file.dir)$($file.name)".Replace('/','\')
        $fileDir = "${proj}\file$($fileDir)"
        return $fileDir
    }

    #### ���s ####

    [System.Console]::WriteLine("---- �t�@�C���G�N�X�|�[�g�J�n ----")

    # �t�@�C�����[�g�����̈ꗗ���擾
    $rootFiles = GetFiles $backlogFileApi "/" $apiKey
    # �f�B���N�g���ȉ����ċA�I�Ɏ擾
    RepeatDir $backlogFileApi $rootFiles $projectKey $apiKey

    [System.Console]::WriteLine("---- �t�@�C���G�N�X�|�[�g�I�� ----")

}
