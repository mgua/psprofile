@echo off
rem mgua@tomware.it 
echo.
echo This file prepares a new user powershell user profile script "profile.ps1"
echo in the current user "Documents" folder
echo.
echo Once created, to activate new profile, open and close powershell window
echo.
echo        USERNAME:%USERNAME%
echo     USERPROFILE:%USERPROFILE%
set PROFILEFILE=profile.ps1
set FULLPROFILEFILE=%USERPROFILE%\Documents\%PROFILEFILE%
echo FULLPROFILEFILE:%FULLPROFILEFILE%
echo.

if exist %FULLPROFILEFILE% goto existing

echo %FULLPROFILEFILE% does not exist. Creating...
copy .\profile.ps1 %FULLPROFILEFILE%

if exist %FULLPROFILEFILE% goto copiedok

echo Unknown Error: %FULLPROFILEFILE% was not created.
goto end

:copiedok
echo %FULLPROFILEFILE% Created.
goto end

:existing
echo %FULLPROFILEFILE% already exists: please rename or delete

:end
