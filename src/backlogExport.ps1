# TLS1.2�ɐ؂�ւ���
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

# �ˑ��t�@�C���̓ǂݍ���
. ".\exportWiki.ps1"
. ".\exportIssue.ps1"
. ".\exportFile.ps1"

# Backlog��API
$BACKLOG_API = "https://spaceId.backlog.jp/api/v2"
# �o�b�N�A�b�v�������v���W�F�N�g�L�[
$PROJECT_KEY = "projectId"
# Backlog��API�L�[
$API_KEY = "backlogApiKey"
# �o�b�N�A�b�v�̏o�͐�
$OUTPUT_DIR = "output"

# �o�b�N�A�b�v�̏o�̓f�B���N�g�����쐬
if (!(Test-Path $OUTPUT_DIR)) {
    New-Item $OUTPUT_DIR -ItemType Directory | Out-Null
}
# �o�̓f�B���N�g���Ɉړ�
Set-Location .\output

Export-Wiki $BACKLOG_API $PROJECT_KEY $API_KEY
Export-Issue $BACKLOG_API $PROJECT_KEY $API_KEY
Export-File $BACKLOG_API $PROJECT_KEY $API_KEY

# �o�̓f�B���N�g�����猳�̃f�B���N�g���ɖ߂�
Set-Location ..\
