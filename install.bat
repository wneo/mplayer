@echo off

setlocal

SET ENABLETEST=1
if "%1"=="noTest" SET ENABLETEST=0

echo "test:%ENABLETEST%"
SET SCRIPTPATH=%~dp0
echo "building ... %SCRIPTPATH%"


:: get current dir name
echo %~p0

set "lj=%~p0"
set "lj=%lj:\= %"
for %%a in (%lj%) do set wjj=%%a
SET DIRNAME=%wjj%


SET SRCDIR=%SCRIPTPATH%src
SET BINPATH=%SCRIPTPATH%bin\%DIRNAME%
SET CURDIR=%SCRIPTPATH%
SET OLDGOPATH=%GOPATH%
SET GOPATH=%CURDIR%

echo "gofmt ..."
gofmt -w %SRCDIR%
SET RESULT=%ERRORLEVEL%
if %RESULT%==0 goto SUCCESS1
:FAIL1
echo "Error: cant fmt <%SRCDIR%> !"
goto FAILED

:SUCCESS1
echo "install ..."
go install %DIRNAME%
SET RESULT=%ERRORLEVEL%
if %RESULT%==0 goto SUCCESS2
:FAIL2
echo "Error: cant install <%DIRNAME%> !"
goto FAILED

:SUCCESS2

if %ENABLETEST%==0 goto SUCCESS

echo %SRCDIR%

::dir %SRCDIR% /s/b/a:-d > path.txt
set CURRENT="1"
for /f  %%a in ('dir %SRCDIR%  /s /b /a-d^|findstr /m "_test.go"') do (
	echo %%a
	)	

:SUCCESS
endlocal


echo Install success.
goto END

:FAILED
endlocal

:END