@echo off
setlocal

rem �p�����^�̓ǂݍ���
set spaceId=%1
set projectKey=%2
rem src�ȉ��Ŏ��s����̂ŏo�̓f�B���N�g����1�K�w�グ�Ă���
set outputDir=..\%3

rem API�L�[�̓ǂݍ���
call auth.bat

cd src
powershell Set-ExecutionPolicy RemoteSigned
powershell .\backlogExport.ps1 %spaceId% %projectKey% %API_KEY% %outputDir%
powershell Set-ExecutionPolicy Restricted
cd ..\
endlocal
@echo on
