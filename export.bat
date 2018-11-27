cd src
powershell Set-ExecutionPolicy RemoteSigned
powershell .\backlogExport.ps1
powershell Set-ExecutionPolicy Restricted
cd ..\
