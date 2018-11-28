function Export-Issue($backlogApiUrl, $projectKey, $apiKey) {

    # Backlog�̉ۑ�֘AAPI���[�g
    $backlogProjApi = "${backlogApiUrl}/projects"
    $backlogIssueApi = "${backlogApiUrl}/issues"

    # �v���W�F�N�g���擾
    function GetProject($baseUrl, $proj, $key) {
        $url = "${baseUrl}/${proj}?apiKey=${key}"
    
        # API��@���ăv���W�F�N�g�����擾
        $res = Invoke-WebRequest "${url}"
        $con = [System.Text.Encoding]::Utf8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($res.Content))
    
        # JSON��z��ɕϊ�
        $project = ConvertFrom-Json $con
        return $project
    }

    # �ۑ�ꗗ�擾
    function GetIssues($baseUrl, $proj, $key) {

        $url = "${baseUrl}?apiKey=${key}&projectId[]=${proj}"

        # API��@���ĉۑ�ꗗ���擾
        $res = Invoke-WebRequest "${url}"
        $con = [System.Text.Encoding]::Utf8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($res.Content))

        # JSON��z��ɕϊ�
        $issues = ConvertFrom-Json $con
        return $issues
    }

    # �ۑ�o�̓f�B���N�g���쐬
    function MakeIssueDir($issue, $proj) {
        $issueDir = $issue.summary
        $issueDir = "${proj}\issue\$($issue.id)-${issueDir}"
        # �ۑ�y�[�W���Ńf�B���N�g�����쐬����
        New-Item $issueDir -ItemType Directory | Out-Null

        return $issueDir
    }

    # �ۑ�{���_�E�����[�h����
    function DownloadIssue($baseUrl, $issue, $issueDir, $key) {

        [System.Console]::WriteLine($issue.summary)

        # �ۑ�y�[�W����API��/api/v2/issues/{issueId}
        $issueUrl = "${baseUrl}/$($issue.id)?apiKey=${key}"
        $res = Invoke-WebRequest "${issueUrl}"
        $con = [System.Text.Encoding]::Utf8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($res.Content))
        $issuedata = ConvertFrom-Json $con

        $issueName = (Split-Path -Leaf $issueDir) + ".md"
        $jsonName = "origin-" + (Split-Path -Leaf $issueDir) + ".json"

        # �t�@�C�����o��
        $issuedata.description | Out-File "${issueDir}\${issueName}" -Encoding UTF8
        $issuedata | ConvertTo-Json | Out-File "${issueDir}\${jsonName}" -Encoding UTF8
    }

    # �ۑ�̃R�����g�ꗗ���擾����
    function GetComments($baseUrl, $issue, $issueDir, $key) {

        $commentUrl = "${baseUrl}/$($issue.id)/comments?apiKey=${key}"
        $res = Invoke-WebRequest "${commentUrl}"
        $con = [System.Text.Encoding]::Utf8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($res.Content))
        $comments = ConvertFrom-Json $con

        return $comments
    }

    # �R�����g���o�͂���i�ۑ�̕ύX�����Ȃǂ��R�����g�Ɋ܂܂��j
    function OutputComment($comment, $issueDir) {
        $jsonName = "origin-$($comment.id).json"
        $jsonFile = "${issueDir}\${jsonName}"

        # �ύX�������܂ރI���W�i����JSON�t�@�C�����o��
        $comment | ConvertTo-Json | Out-File $jsonFile -Encoding UTF8

        # �R�����g�����Ă�����̂̂ݏ����E����
        if ($null -ne $comment.content) {
            $commentName = "comment-$($comment.id).txt"
            $commentFile = "${issueDir}\${commentName}"
            "���[�U�[�F$($comment.createdUser.name)" | Out-File $commentFile -Encoding UTF8 -Append
            "�o�^�����F$($comment.created)" | Out-File $commentFile -Encoding UTF8 -Append
            "�X�V�����F$($comment.updated)" | Out-File $commentFile -Encoding UTF8 -Append
            "�X�V�t�B�[���h�F$($comment.changeLog.field)" | Out-File $commentFile -Encoding UTF8 -Append
            "�ύX�O�F$($comment.changeLog.originalValue)" | Out-File $commentFile -Encoding UTF8 -Append
            "�ύX��F$($comment.changeLog.newValue)" | Out-File $commentFile -Encoding UTF8 -Append
            "�R�����g�F$($comment.content)" | Out-File $commentFile -Encoding UTF8 -Append
        }
    }

    # �Y�t�t�@�C���_�E�����[�h
    function DownloadAttachedFile($baseUrl, $issueId, $attachment, $issueDir, $key) {
        $attachemtApiUrl = "${baseUrl}/${issueId}/attachments/$($attachment.id)?apiKey=${key}"
        Invoke-WebRequest "${attachemtApiUrl}" -OutFile "${issueDir}\$($attachment.id)_$($attachment.name)"
    }

    #### ���s ####

    [System.Console]::WriteLine("---- �ۑ�G�N�X�|�[�g�J�n ----")

    # �v���W�F�N�g���擾
    $project = GetProject $backlogProjApi $projectKey $apiKey
    # �ۑ�ꗗ�擾
    $issueList = GetIssues $backlogIssueApi $project.id $apiKey
    # �ۑ���_�E�����[�h
    foreach ($issue in $issueList) {
        $issueDir = MakeIssueDir $issue $project.projectKey

        DownloadIssue $backlogIssueApi $issue $issueDir $apiKey

        # �R�����g�ꗗ���擾
        $commentList = GetComments $backlogIssueApi $issue $issueDir $apiKey
        # �R�����g���_�E�����[�h
        foreach ($comment in $commentList) {
            OutputComment $comment $issueDir
        }
        # �Y�t�t�@�C�����_�E�����[�h
        foreach($attachment in $issue.attachments) {
            DownloadAttachedFile $backlogIssueApi $issue.id $attachment $issueDir $apiKey
        }

    }

    [System.Console]::WriteLine("---- �ۑ�G�N�X�|�[�g�I�� ----")

}