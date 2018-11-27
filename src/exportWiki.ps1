function Export-Wiki($backlogApiUrl, $projectKey, $apiKey) {

    # Backlog��Wiki�֘AAPI���[�g
    $backlogWikiApi = "${backlogApiUrl}/wikis"

    # wiki�ꗗ���擾
    function GetWikiList($baseUrl, $proj, $key) {
        $url = "${baseUrl}?apiKey=${key}&projectIdOrKey=${proj}"

        # API��@����wiki�ꗗ���擾
        $res = Invoke-WebRequest "${url}"
        $con = [System.Text.Encoding]::Utf8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($res.Content))

        # JSON��z��ɕϊ�
        $wikis = ConvertFrom-Json $con
        return $wikis
    }

    # Wiki�o�̓f�B���N�g���쐬
    function MakeWikiDir($wiki, $proj) {
        $wikiDir = $wiki.name.Replace('/','\')
        $wikiDir = "${proj}\wiki\${wikiDir}"
        # Wiki�y�[�W��(�K�w�܂�)�Ńf�B���N�g�����쐬����
        New-Item $wikiDir -ItemType Directory | Out-Null

        return $wikiDir
    }
    # Wiki�{���_�E�����[�h����
    function DownloadWiki($baseUrl, $wiki, $wikiDir, $key) {

        [System.Console]::WriteLine($wiki.name)

        # �_�E�����[�h
        $wikiUrl = "${baseUrl}/$($wiki.id)?apiKey=${key}"
        $res = Invoke-WebRequest "${wikiUrl}"
        $con = [System.Text.Encoding]::Utf8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($res.Content))
        $wikidata = ConvertFrom-Json $con

        # �t�@�C�������쐬
        $wikiName = (Split-Path -Leaf $wikiDir) + ".md"
        $jsonName = "origin-" + (Split-Path -Leaf $wikiDir) + ".json"

        # �t�@�C�����o��
        $wikidata.content | Out-File "${wikiDir}\${wikiName}" -Encoding UTF8
        $wikidata | ConvertTo-Json | Out-File "${wikiDir}\${jsonName}" -Encoding UTF8
    }

    # �Y�t�t�@�C���_�E�����[�h
    function DownloadAttachedFile($baseUrl, $wikiId, $attachment, $dir, $key) {
        $attachemtApiUrl = "${baseUrl}/${wikiId}/attachments/$($attachment.id)?apiKey=${key}"
        Invoke-WebRequest "${attachemtApiUrl}" -OutFile "${dir}\$($attachment.id)_$($attachment.name)"
    }

    #### ���s ####

    [System.Console]::WriteLine("---- Wiki�G�N�X�|�[�g�J�n ----")

    # wiki�ꗗ���擾
    $wikiList = GetWikiList $backlogWikiApi $projectKey $apiKey
    # wiki���_�E�����[�h
    foreach ($wiki in $wikiList) {
        # �o�̓f�B���N�g���쐬
        $dir = MakeWikiDir $wiki $projectKey
        # wiki�y�[�W���_�E�����[�h
        DownloadWiki $backlogWikiApi $wiki $dir $apiKey
        # �Y�t�t�@�C�����_�E�����[�h
        foreach($attachment in $wiki.attachments) {
            DownloadAttachedFile $backlogWikiApi $wiki.id $attachment $dir $apiKey
        }
    }

    [System.Console]::WriteLine("---- Wiki�G�N�X�|�[�g�I�� ----")

}
