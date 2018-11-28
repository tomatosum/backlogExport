Param($spaceId, $projectKey, $apiKey, $outputDir)

# TLS1.2�ɐ؂�ւ���
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

# �ˑ��t�@�C���̓ǂݍ���
. ".\exportWiki.ps1"
. ".\exportIssue.ps1"
. ".\exportFile.ps1"

# BacklogAPI��URL
$BACKLOG_API = "https://${spaceId}.backlog.jp/api/v2"

# �o�b�N�A�b�v�̏o�̓f�B���N�g�����쐬
if (!(Test-Path $outputDir)) {
    New-Item $outputDir -ItemType Directory | Out-Null
}

# ���݂̃f�B���N�g�����擾
$currentDir = [System.IO.Directory]::GetCurrentDirectory()

# �o�̓f�B���N�g���Ɉړ�
Set-Location $outputDir

Export-Wiki $BACKLOG_API $projectKey $apiKey
Export-Issue $BACKLOG_API $projectKey $apiKey
Export-File $BACKLOG_API $projectKey $apiKey

# �o�̓f�B���N�g�����猳�̃f�B���N�g���ɖ߂�
Set-Location $currentDir
