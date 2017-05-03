@echo off
set nuketoolver=v2.0.0.0-beta1

pushd %~dp0
set pwd=%~dp0

Title TPS_NUKE %nuketoolver%
Color f0

::CHECK FOR LOCAL CONFIG FILE
set ININAME=nuke_config.ini
IF NOT EXIST "%~dp0%ininame%" GOTO :set_default_values

rem %0 is the script file name (with path), %~0 removes the surrounding " " ("%~0" == %0)
rem Adding dp returns the drive and path to the file, instead of the file name itself
set INISTATUS=Present
set INIFILE="%~dp0%ininame%"
call:getvalue %INIFILE% "appserver" "" APPSERVER
call:getvalue %INIFILE% "sqlserver" "" SQLSERVER
call:getvalue %INIFILE% "domain" "" DOMAIN
call:getvalue %INIFILE% "tpsuser" "" TPSUSER
call:getvalue %INIFILE% "tpspass" "" TPSPASS
call:getvalue %INIFILE% "tpsver" "" TPSVER
call:getvalue %INIFILE% "drincode" "" DRINCODE
call:getvalue %INIFILE% "tpssource" "" TPSSOURCE
call:getvalue %INIFILE% "PSAppProxyPath" "" PSAPPPROXYPATH
call:getvalue %INIFILE% "DotNetVer" "" DOTNETVER
call:getvalue %INIFILE% "DotNetPath" "" DOTNETPATH
call:getvalue %INIFILE% "BatchDir" "" BATCHDIR
call:getvalue %INIFILE% "bolayer" "" BOLAYER
call:getvalue %INIFILE% "ThirdParty32" "" THIRDPARTY32
call:getvalue %INIFILE% "ThirdParty64" "" THIRDPARTY64
call:getvalue %INIFILE% "iconcache" "" ICONCACHE
goto:ask

:getvalue
rem This function reads a value from an INI file and stored it in a variable
rem %1 = name of ini file to search in.
rem %2 = search term to look for
rem %3 = group name (not currently used)
rem %4 = variable to place search result
FOR /F "eol=; eol=[ tokens=1,2* delims==" %%i in ('findstr /b /l /i %~2= %1') DO set %~4=%%~j
goto:eof

:set_default_values
set INIFILE=%ininame%
set INISTATUS=Not Present

set appserver=**APPSERVER**
set sqlserver=**SQLSERVER**
set domain=m**DOMAIN**
set tpsuser=**USERNAME**
set tpspass=**PASSWORD**
set tpsver=2016.4.17
set drincode="DrIncodeClientSetup.exe"
set tpssource="Tyler Technologies\*"
set PSAppProxyPath="PSAppProxy.msi"
set DotNetVer=4.6.2
set DotNetPath="NDP462-KB3151800-x86-x64-AllOS-ENU.exe"
set BatchDir=scripts\
set bolayer=PublicSafety BO Layer (Application Proxy)
set ThirdParty32=Tyler Public Safety - 3rd Party Components
set ThirdParty64=Tyler Public Safety - 3rd Party Components 64 Bit
set iconcache=%localappdata%\IconCache.db

:ask
cls
MODE CON:COLS=90 LINES=35
echo.
echo -----------------------------------------------------------------------------------------
echo            8888888888 d8b            88888888888      888	APP Svr: %appserver%
echo            888        Y8P                888          888	SQL Svr: %sqlserver%
echo            888                           888          888
echo            8888888    888 888  888       888 888  888 888  .d88b.  888d888
echo            888        888 `Y8bd8P'       888 888  888 888 d8P  Y8b 888P"
echo            888        888   X88K         888 888  888 888 88888888 888
echo            888        888 .d8""8b.       888 Y88b 888 888 Y8b.     888
echo            888        888 888  888       888  "Y88888 888  "Y8888  888
echo                                                   888
echo                                              Y8b d88P
echo                                               "Y88P"
echo               Config: %ininame%
echo          Config File: %inistatus%
echo            NUKE_USER: %username%
echo             NUKE_DIR: %cd%
echo             TPS User: %domain%\%tpsuser%
echo         Nuke Version: %nuketoolver%
echo -----------------------------------------------------------------------------------------
echo       Enter " 1 " --^> TPS Quick Repair (includes options 5, 6, and 7)
echo       Enter " 2 " -----^> !!! COMPLETELY NUKE TPS FROM ORBIT !!!
echo       Enter " 3 " --------^> Install TPS (includes option 4, 5, 6 and 7)
echo       Enter " 4 " ----------^> Install .NET Framework %DotNetVer%
echo       Enter " 5 " ------------^> Restart DrIncode Service (update credentials)
echo       Enter " 6 " ----------^> Fix ActiveX Error 457 (Reinstall BO Layer)
echo       Enter " 7 " --------^> Disable the Windows Firewall Service
echo       Enter " 8 " -----^> Fix Permissions on the Tyler Technologies Folder
echo       Enter " 9 " --^> Run Scripts from "%BatchDir%"
echo       Enter " X " to close this window
echo -----------------------------------------------------------------------------------------
echo.
set INPUT=
set /P INPUT=Choice: %=%
IF /I "%INPUT%"=="1" GOTO repair
IF /I "%INPUT%"=="2" GOTO remove
IF /I "%INPUT%"=="3" GOTO install
IF /I "%INPUT%"=="4" GOTO dotnet
IF /I "%INPUT%"=="5" GOTO restart_drincode
IF /I "%INPUT%"=="6" GOTO bolayer
IF /I "%INPUT%"=="7" GOTO firewall
IF /I "%INPUT%"=="8" GOTO permissions
IF /I "%INPUT%"=="9" GOTO externalscripts
IF /I "%INPUT%"=="X" GOTO close
echo.
echo Incorrect Input!
TIMEOUT /T 3 /NOBREAK > NUL
GOTO ask
echo.

:repair
call :repair_1
GOTO end
:repair_1
echo.
echo Performing Quick Repair Please Wait...
echo.
echo.
IF NOT EXIST "C:\Program Files\Tyler Technologies\" echo Tyler is not Installed!! Proceeding to reinstall...
TIMEOUT /T 5 /NOBREAK > NUL
IF NOT EXIST "C:\Program Files\Tyler Technologies\" GOTO :install
call :stopservice_1
echo Removing TPS Applications Folder...
RD /S /Q "C:\Program Files\Tyler Technologies\DrIncode\Applications\"
echo.
call :bolayer_1
echo DrIncode Service Cleanup...
"C:\Program Files\Tyler Technologies\DrIncode\InstallUtil\DynamicInstallUtil.exe" -uninstall -n NGS_DoctorIncodeService -d "C:\Program Files\Tyler Technologies\DrIncode" -a Foundation.DoctorIncode.WinServiceHost.exe
echo.
echo.
echo Deleting DrIncode Service...
SC DELETE NGS_DoctorIncodeService
echo.
echo.
echo Deleting AVL Client Service...
SC DELETE NGS_TPS_TPSAvlClientService
echo.
echo.
:repair_2
echo Installing DrIncode Service...
"C:\Program Files\Tyler Technologies\DrIncode\InstallUtil\DynamicInstallUtil.exe" -n "NGS_DoctorIncodeService" -d "C:\Program Files\Tyler Technologies\DrIncode" -a Foundation.DoctorIncode.WinServiceHost.exe -t User -u %domain%\%tpsuser% -p %tpspass%
echo.
call :bolayer_2
echo Cleanup...
RD /S /Q "C:\Program Files\Tyler Technologies\DrIncode\Services\NGS_DoctorIncodeService"
echo.
echo.
echo Deleting Desktop Icons...
DEL "%PUBLIC%\Desktop\CAD*.lnk"
DEL "%PUBLIC%\Desktop\RMS*.lnk"
DEL "%PUBLIC%\Desktop\Mobile Citations*.lnk"
echo.
echo.
call :firewall_1
call :permissions_1
call :startservice_1
TIMEOUT /T 10 /NOBREAK > NUL
call :stopservice_1
call :startservice_1
GOTO :EOF

:remove
call :remove_1
GOTO end
:remove_1
echo.
echo.
echo                          ____/ (  (    )   )  \___
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                         /( (  (  )   _    ))  )   )\
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                       ((     (   )(    )  )   (   )  )
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                     ((/  ( _(   )   (   _) ) (  () )  )
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                    ( (  ( (_)   ((    (   )  .((_ ) .  )_
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                   ( (  )    (      (  )    )   ) . ) (   )
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                  (  (   (  (   ) (  _  ( _) ).  ) . ) ) ( )
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                  ( (  (   ) (  )   (  ))     ) _)(   )  )  )
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                 ( (  ( \ ) (    (_  ( ) ( )  )   ) )  )) ( )
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                  (  (   (  (   (_ ( ) ( _    )  ) (  )  )   )
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                 ( (  ( (  (  )     (_  )  ) )  _)   ) _( ( )
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                  ((  (   )(    (     _    )   _) _(_ (  (_ )
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                   (_((__(_(__(( ( ( ^|  ) ) ) )_))__))_)___)
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                   ((__)        \\^|^|lll^|l^|^|///          \_))
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                                 ^|^|\(^|(^|)^|/^|^|
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                                 ^|^|\(^|(^|)^|/^|^|     
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                          (      ^|^|\(^|(^|)^|/^|^|     )
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                     (           ^|(^|^|(^|^|)^|^|^|^|         )
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                          (     //^|/l^|^|^|)^|\\ \     )
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                                 ^|^|\(^|(^|)^|/^|^|     
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                                 ^|^|\(^|(^|)^|/^|^|   
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                                 ^|^|\(^|(^|)^|/^|^|   
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo                        (/ / //  /^|//^|^|^|^|\\  \ \  \ _)
pathping 127.0.0.1 -n -q 1 -p 100 > NUL
echo ----------------------------------------------------------------------------------------
echo.
echo Nuking Tyler Public Safety Please Wait...
TIMEOUT /T 5 /NOBREAK > NUL
echo.
echo Stopping Services and Programs...
taskkill /f /im Foundation.DoctorIncode.WinServiceHost.exe
taskkill /f /im TCILocalServerApp.exe
taskkill /f /im MobileCADClient.exe
taskkill /f /im TylerTech.TPS.Mapping.MapClient.exe
taskkill /f /im "Keyboard Wedge.exe"
taskkill /f /im TPSClientSetup.exe
taskkill /f /im AppInstallUtil.exe
echo.
echo Stopping DrIncode Service...
NET STOP NGS_DoctorIncodeService
echo.
echo.
echo DrIncode Service Cleanup...
"C:\Program Files\Tyler Technologies\DrIncode\InstallUtil\DynamicInstallUtil.exe" -uninstall -n NGS_DoctorIncodeService -d "C:\Program Files\Tyler Technologies\DrIncode" -a Foundation.DoctorIncode.WinServiceHost.exe
echo.
echo.
SC DELETE NGS_DoctorIncodeService
echo.
echo.
echo Deleting AVL Client Service...
SC DELETE NGS_TPS_TPSAvlClientService
echo.
echo.
echo Removing 32-bit 3rd Party Components...
wmic product where name="%ThirdParty32%" call uninstall
echo.
echo.
echo Removing 64-bit 3rd Party Components...
wmic product where name="%ThirdParty64%" call uninstall
echo.
call :bolayer_1
echo Cleaning TylerTechnologies HKLM Registry Entries...
REG DELETE HKEY_LOCAL_MACHINE\SOFTWARE\TylerTechnologies\ /f
echo.
echo.
echo Cleaning TylerTechnologies HKLM Wow6432Node Registry Entries...
REG DELETE HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\TylerTechnologies\ /f
echo.
echo.
echo Removing Tyler Technologies Program Files Folder...
:nuke_folder
TIMEOUT /T 5 /NOBREAK > NUL
RD /S /Q "C:\Program Files\Tyler Technologies\"
echo.
echo.
IF EXIST "C:\Program Files\Tyler Technologies\" GOTO nuke_folder
TIMEOUT /T 3 /NOBREAK > NUL
echo.
echo Removing Log Files...
DEL C:\PSProxInstallLog.txt
DEL C:\PSProxUnInstallLog.txt
DEL "%PUBLIC%\Desktop\CAD*.lnk"
DEL "%PUBLIC%\Desktop\RMS*.lnk"
DEL "%PUBLIC%\Desktop\Mobile CAD*.lnk"
DEL "%PUBLIC%\Desktop\Mobile Citations*.lnk"
echo.
echo.
GOTO :EOF

:install
IF EXIST "C:\Program Files\Tyler Technologies\" call :remove_1
echo Is this a new Tyler install? 
echo.
set INPUT=
set /P INPUT=(Y/N): %=%
IF /I "%INPUT%"=="Y" GOTO install_2
IF /I "%INPUT%"=="N" GOTO reinstall
:install_2
start /wait cmd /c "%drincode%"
TIMEOUT /T 30 /NOBREAK > NUL
call :stopservice_1
TIMEOUT /T 3 /NOBREAK > NUL
cls
call :dotnet_2
call :bolayer_2
call :firewall_1
call :startservice_1
GOTO end

:reinstall
IF NOT EXIST "C:\Program Files\Tyler Technologies\" GOTO reinstall_2
call :remove_1
:reinstall_2
xcopy "%tpssource%" "C:\Program Files\Tyler Technologies" /s /i
echo.
echo.
TIMEOUT /T 3 /NOBREAK > NUL
:reinstall_3
call :dotnet_2
call :repair_2
TIMEOUT /T 10 /NOBREAK > NUL
GOTO end

:restart_drincode
call :stopservice_1
call :startservice_1
GOTO end

:stopservice
call :stopservice_1
GOTO end
:stopservice_1
echo Stopping DrIncode Service...
sc.exe stop "NGS_DoctorIncodeService"
taskkill /f /im Foundation.DoctorIncode.WinServiceHost.exe
echo.
echo.
GOTO :EOF

:startservice
call :startservice_1
pause
GOTO end
:startservice_1
echo Starting DrIncode Service...
sc.exe config "NGS_DoctorIncodeService" obj= "%domain%\%tpsuser%" password= "%tpspass%"
sc.exe start "NGS_DoctorIncodeService"
echo.
echo.
GOTO :EOF

:dotnet
call :dotnet_2
TIMEOUT /T 3 /NOBREAK > NUL
GOTO end
:dotnet_2
echo.
echo Finding Installed .NET Framework Version Please Wait...
echo.
wmic product where "Name like 'Microsoft .Net %%'" get Name
echo.
:ask_2
echo Would you like to install/reinstall .NET Framework %DotNetVer%? 
echo.
set INPUT=
set /P INPUT=(Y/N): %=%
IF /I "%INPUT%"=="Y" GOTO dotnet_3
IF /I "%INPUT%"=="N" GOTO :EOF
echo.
echo Incorrect Input!
TIMEOUT /T 3 /NOBREAK > NUL
GOTO ask_2
:dotnet_3
echo.
echo Installing .NET Framework %DotNetVer%...
"%DotNetPath%" /passive /promptrestart
echo.
echo.
GOTO :EOF

:bolayer
call :bolayer_1
call :bolayer_2
TIMEOUT /T 3 /NOBREAK > NUL
GOTO end
:bolayer_1
echo.
echo Removing PublicSafety BO Layer...
wmic product where name="%bolayer%" call uninstall
echo.
echo.
GOTO :EOF
:bolayer_2
echo Is this a MobileCAD Machine?
echo.
set INPUT=
set /P INPUT=(Y/N): %=%
IF /I "%INPUT%"=="Y" GOTO :EOF
IF /I "%INPUT%"=="N" GOTO bolayer_3
:bolayer_3
echo Installing PublicSafety BO Layer...
msiexec.exe /passive /package "%PSAppProxyPath%"
echo.
echo.
GOTO :EOF

:firewall
call :firewall_1
TIMEOUT /T 3 /NOBREAK > NUL
GOTO end
:firewall_1
echo.
echo Stopping Windows Firewall Service...
NET STOP MpsSvc
echo.
echo.
echo Changing Windows Firewall Service Startup to Disabled...
sc.exe config MpsSvc start= disabled
echo.
echo.
GOTO :EOF

:permissions
call :permissions_1
GOTO end
:permissions_1
echo.
echo Running Checks...
IF EXIST "C:\Program Files\Tyler Technologies\" GOTO :permissions_2
echo.
echo TYLER IS NOT INSTALLED!
echo.
TIMEOUT /T 5 /NOBREAK > NUL
GOTO :EOF
:permissions_2
echo Resetting Permissions on Tyler Technologies Folder to Inherited...
icacls "C:\Program Files\Tyler Technologies" /reset /c /t
echo.
echo.
TIMEOUT /T 5 /NOBREAK > NUL
echo Granting Domain Users Full Control to Tyler Technologies Folder...
icacls "C:\Program Files\Tyler Technologies" /grant "Domain Users":(OI)(CI)F /c /t
echo.
echo.
TIMEOUT /T 5 /NOBREAK > NUL
GOTO :EOF

:externalscripts
Setlocal ENABLEDELAYEDEXPANSION
:buildmenu
set /A MAXITEM=0
FOR /f "delims=" %%M in ('"dir /b /a-d "%BatchDir%*.bat""') do (
	set /A MAXITEM=!MAXITEM!+1
	set MENUITEM!MAXITEM!=%%M
)
:showmenu
cls
echo -----------------------------------------------------------------------------------------
echo                                  EXTERNAL SCRIPTS
echo -----------------------------------------------------------------------------------------
set CHOICE=0
FOR /L %%I in (1,1,!MAXITEM!) do echo    %%I. !MENUITEM%%I!
echo.
set /P CHOICE="Select script to run or choose "X" to return to main menu: "
echo.
IF %CHOICE%==x GOTO end
IF %CHOICE%==X GOTO end
IF %CHOICE% Gtr !MAXITEM! GOTO showmenu
IF %CHOICE%==0 GOTO showmenu
:callbat
FOR /f "delims=" %%S in ("!MENUITEM%CHOICE%!") Do set SCRIPTNAME=%%S
echo calling Script "%SCRIPTNAME%"
echo.
set /P YESNO="Are you sure (Y/N): "
IF NOT %YESNO%==y IF NOT %YESNO%==Y GOTO showmenu
cls
call "%BatchDir%%SCRIPTNAME%"
GOTO showmenu

:end
Setlocal DISABLEDELAYEDEXPANSION
cls
echo -----------------------------------------------------------------------------------------
echo                                      FINISHED
echo -----------------------------------------------------------------------------------------
echo.
echo.
echo.
echo.
TIMEOUT /T 5 /NOBREAK > NUL
GOTO ask

:restart
echo Restarting Machine...
TIMEOUT /T 5 /NOBREAK > NUL
shutdown -r -t 0
TIMEOUT /T 30 /NOBREAK > NUL

:close
echo Would you restart this machine? 
echo.
set INPUT=
set /P INPUT=(Y/N): %=%
IF /I "%INPUT%"=="Y" GOTO restart
IF /I "%INPUT%"=="N" GOTO :close_2
echo.
echo Incorrect Input!
TIMEOUT /T 3 /NOBREAK > NUL

:close_2