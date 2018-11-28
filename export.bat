@echo off
setlocal

rem パラメタの読み込み
set spaceId=%1
set projectKey=%2
rem src以下で実行するので出力ディレクトリは1階層上げておく
set outputDir=..\%3

rem APIキーの読み込み
call auth.bat

cd src
powershell Set-ExecutionPolicy RemoteSigned
powershell .\backlogExport.ps1 %spaceId% %projectKey% %API_KEY% %outputDir%
powershell Set-ExecutionPolicy Restricted
cd ..\
endlocal
@echo on
