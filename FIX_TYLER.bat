@echo off
::DEFINE VARIABLES HERE
SET server=**SERVERNAME**
SET username=**DOMAIN\USERNAME**
SET password=**PASSWORD**
SET tpsver=2016.3.12
SET tps_source="\\%server%\TPSLicense\VERSIONS\%tpsver%\Tyler Technologies\*"
::PACKAGE PATHS
SET PSAppProxyPath="\\%server%\PublicSafety\Updates\ApplicationProxy\PSAppProxy.msi"
SET DotNetVer=4.6.2
SET DotNetPath="\\%server%\TPSLicense\NDP462-KB3151800-x86-x64-AllOS-ENU.exe"
::WMIC VALUES
SET bolayer=PublicSafety BO Layer (Application Proxy)
SET ThirdParty32=Tyler Public Safety - 3rd Party Components
SET ThirdParty64=Tyler Public Safety - 3rd Party Components 64 Bit
::ENVIROMENTAL
SET iconcache=%localappdata%\IconCache.db

:ask
echo.
echo -------------------------------------------------------------------------------
echo       8888888888 d8b            88888888888      888	  Server: %server%
echo       888        Y8P                888          888	     TPS: %tpsver%
echo       888                           888          888
echo       8888888    888 888  888       888 888  888 888  .d88b.  888d888
echo       888        888 `Y8bd8P'       888 888  888 888 d8P  Y8b 888P"
echo       888        888   X88K         888 888  888 888 88888888 888
echo       888        888 .d8""8b.       888 Y88b 888 888 Y8b.     888
echo       888        888 888  888       888  "Y88888 888  "Y8888  888
echo                                              888
echo                                         Y8b d88P
echo                                          "Y88P"	       Nuke Tool: v1.0.6.0
echo -------------------------------------------------------------------------------
echo  Enter " 1 " --^> TPS Quick Repair (includes options 5, 6, and 7)
echo  Enter " 2 " -----^> !!! COMPLETELY NUKE TPS FROM ORBIT !!!
echo  Enter " 3 " --------^> Reinstall TPS (includes option 2, 4, 5, 6 and 7)
echo  Enter " 4 " ----------^> Install .NET Framework %DotNetVer%
echo  Enter " 5 " ----------^> Fix ActiveX Error 457 (Reinstall BO Layer)
echo  Enter " 6 " --------^> Disable the Windows Firewall Service
echo  Enter " 7 " -----^> Fix Permissions on the Tyler Technologies Folder
echo  Enter " 8 " --^> Fix Blank or Incorrect Desktop Icons
echo  Enter " X " to close this window
echo -------------------------------------------------------------------------------
echo.
set INPUT=
set /P INPUT=Choice: %=%
If /I "%INPUT%"=="1" goto repair
If /I "%INPUT%"=="2" goto remove
If /I "%INPUT%"=="3" goto reinstall
If /I "%INPUT%"=="4" goto dotnet
If /I "%INPUT%"=="5" goto bolayer
If /I "%INPUT%"=="6" goto firewall
If /I "%INPUT%"=="7" goto permissions
If /I "%INPUT%"=="8" goto iconcache
If /I "%INPUT%"=="X" goto close
echo.
echo Incorrect Input!
TIMEOUT /T 3 /NOBREAK > NUL
goto ask
echo.

:repair
call :repair_1
goto end
:repair_1
echo.
echo Performing Quick Repair Please Wait...
echo.
echo.
IF NOT EXIST "C:\Program Files\Tyler Technologies\" echo Tyler is not Installed!! Proceeding to reinstall...
TIMEOUT /T 5 /NOBREAK > NUL
IF NOT EXIST "C:\Program Files\Tyler Technologies\" goto :install
echo Stopping DrIncode Service...
NET STOP NGS_DoctorIncodeService
echo.
echo.
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
"C:\Program Files\Tyler Technologies\DrIncode\InstallUtil\DynamicInstallUtil.exe" -n "NGS_DoctorIncodeService" -d "C:\Program Files\Tyler Technologies\DrIncode" -a Foundation.DoctorIncode.WinServiceHost.exe -t User -u %username% -p %password%
echo.
call :bolayer_2
echo Cleanup...
RD /S /Q "C:\Program Files\Tyler Technologies\DrIncode\Services\NGS_DoctorIncodeService"
echo.
echo.
call :firewall_1
call :permissions_1
echo Starting DrIncode Service...
sc start "NGS_DoctorIncodeService"
echo.
echo.
GOTO :EOF

:remove
call :remove_1
goto end
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
echo ------------------------------------------------------------------------------
echo.
echo Nuking Tyler Public Safety Please Wait...
TIMEOUT /T 5 /NOBREAK > NUL
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
IF EXIST "C:\Program Files\Tyler Technologies\" goto nuke_folder
TIMEOUT /T 3 /NOBREAK > NUL
echo Removing INCODE ProgramData Folder...
RD /S /Q "C:\ProgramData\INCODE\"
echo.
echo.
echo Removing Log Files...
DEL C:\PSProxInstallLog.txt
DEL C:\PSProxUnInstallLog.txt
echo.
echo.
GOTO :EOF

:reinstall
IF NOT EXIST "C:\Program Files\Tyler Technologies\" goto install
call :remove_1
:install
xcopy %tps_source% "C:\Program Files\Tyler Technologies" /s /i
echo.
echo.
TIMEOUT /T 3 /NOBREAK > NUL
call :dotnet_2
call :repair_2
TIMEOUT /T 10 /NOBREAK > NUL
echo Stopping DrIncode Service...
sc stop "NGS_DoctorIncodeService"
echo.
echo.
echo Starting DrIncode Service...
sc start "NGS_DoctorIncodeService"
echo.
echo.
goto end

:dotnet
call :dotnet_2
TIMEOUT /T 3 /NOBREAK > NUL
goto end
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
If /I "%INPUT%"=="Y" goto dotnet_3
If /I "%INPUT%"=="N" goto :EOF
echo.
echo Incorrect Input!
TIMEOUT /T 3 /NOBREAK > NUL
goto ask_2
:dotnet_3
echo.
echo Installing .NET Framework %DotNetVer%...
%DotNetPath% /passive /promptrestart
echo.
echo.
GOTO :EOF

:bolayer
call :bolayer_1
call :bolayer_2
TIMEOUT /T 3 /NOBREAK > NUL
goto end
:bolayer_1
echo.
echo Removing PublicSafety BO Layer...
wmic product where name="%bolayer%" call uninstall
echo.
echo.
GOTO :EOF
:bolayer_2
echo Installing PublicSafety BO Layer...
msiexec.exe /passive /package %PSAppProxyPath%
echo.
echo.
GOTO :EOF

:firewall
call :firewall_1
TIMEOUT /T 3 /NOBREAK > NUL
goto end
:firewall_1
echo.
echo Stopping Windows Firewall Service...
NET STOP MpsSvc
echo.
echo.
echo Changing Windows Firewall Service Startup to Disabled...
sc config MpsSvc start= disabled
echo.
echo.
GOTO :EOF

:permissions
call :permissions_1
goto end
:permissions_1
echo.
echo Running Checks...
IF EXIST "C:\Program Files\Tyler Technologies\" goto :permissions_2
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

:iconcache
echo.
echo The Explorer process must be killed to delete the Icon DB... 
echo.
echo Please SAVE ALL OPEN WORK before continuing!!
echo.
pause
echo.
If exist "%iconcache%" goto delID
echo.
echo Icon DB has already been deleted...
goto end

:delID
echo Attempting to delete Icon DB...
ie4uinit.exe -ClearIconCache
echo.
echo.
taskkill /IM explorer.exe /F 
echo.
echo.
del "%iconcache%" /A
echo.
echo.
start explorer.exe
echo.
echo.
goto end

:end
echo -------------------------------------------------------------------------------
echo                                 FINISHED
echo -------------------------------------------------------------------------------
echo.
echo.
echo.
echo.
TIMEOUT /T 5 /NOBREAK > NUL
goto ask

:restart
echo Restarting Machine...
TIMEOUT /T 5 /NOBREAK > NUL
shutdown -r -t 0

:close
echo Would you restart this machine? 
echo.
set INPUT=
set /P INPUT=(Y/N): %=%
If /I "%INPUT%"=="Y" goto restart
If /I "%INPUT%"=="N" goto :close_2
echo.
echo Incorrect Input!
TIMEOUT /T 3 /NOBREAK > NUL

:close_2
