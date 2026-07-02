@echo off
title GONX T2R TMM - Bypass Free Fire Max
color 0a

for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
echo ========================================
echo        %ESC%[97mGONX T2R TMM%ESC%[91m MENU%ESC%[0m
echo ========================================
echo.

set ADB_DIR=
set ADB_EXE=adb
set ADB_PORT=
set DEVICE=

:: ========== CRIA O SemTela.json ==========
call :log "[*] ********** **********..."
set "JSON_FILE=%TEMP%\SemTela.json"
echo {^"fakeVersion^":^"2.126.3^"} > "%JSON_FILE%"

:: ========== PROCURA ADB ==========
where adb 2>nul >nul
if %errorlevel% equ 0 goto :achou_adb

if exist "%ProgramFiles%\BlueStacks_nxt\HD-Adb.exe" set "ADB_DIR=%ProgramFiles%\BlueStacks_nxt" & set ADB_EXE=HD-Adb.exe
if not defined ADB_DIR if exist "%ProgramFiles(x86)%\BlueStacks_nxt\HD-Adb.exe" set "ADB_DIR=%ProgramFiles(x86)%\BlueStacks_nxt" & set ADB_EXE=HD-Adb.exe
if not defined ADB_DIR if exist "%ProgramFiles%\BlueStacks_nxt\Engine\Tools\adb.exe" set "ADB_DIR=%ProgramFiles%\BlueStacks_nxt\Engine\Tools" & set ADB_EXE=adb.exe
if not defined ADB_DIR if exist "%ProgramFiles(x86)%\BlueStacks_nxt\Engine\Tools\adb.exe" set "ADB_DIR=%ProgramFiles(x86)%\BlueStacks_nxt\Engine\Tools" & set ADB_EXE=adb.exe
if not defined ADB_DIR if exist "%ProgramFiles%\Nox\bin\nox_adb.exe" set "ADB_DIR=%ProgramFiles%\Nox\bin" & set ADB_EXE=nox_adb.exe
if not defined ADB_DIR if exist "%ProgramFiles(x86)%\Nox\bin\nox_adb.exe" set "ADB_DIR=%ProgramFiles(x86)%\Nox\bin" & set ADB_EXE=nox_adb.exe
if not defined ADB_DIR if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" set "ADB_DIR=%LOCALAPPDATA%\Android\Sdk\platform-tools" & set ADB_EXE=adb.exe
if not defined ADB_DIR if exist "%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools\adb.exe" set "ADB_DIR=%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools" & set ADB_EXE=adb.exe

:achou_adb
if not defined ADB_DIR if "%ADB_EXE%"=="adb" set "ADB_DIR=."
if not defined ADB_DIR (
    call :log "[ERROR] ********* *********!"
    echo.
    call :log "**** **********: **** ^> *********** ^> ****** *** ****"
    pause
    exit /b 1
)

:: Vai pra pasta do ADB
pushd "%ADB_DIR%"
call :log "[0K] ***: %CD%\%ADB_EXE%"

call :log "[*] *********** ******* ***..."
%ADB_EXE% kill-server >nul 2>nul
%ADB_EXE% start-server >nul 2>nul

:: Verifica dispositivo
for /f "tokens=1" %%a in ('%ADB_EXE% devices 2^>nul ^| findstr /v "List" ^| findstr /v "offline" ^| findstr "."') do set DEVICE=%%a

if not defined DEVICE (
    set ADB_PORT=5555
    call :log "[*] ********** *** 127.0.0.1:%ADB_PORT%..."
    %ADB_EXE% connect 127.0.0.1:%ADB_PORT% >nul

    %ADB_EXE% get-state >nul 2>nul
    if %errorlevel% neq 0 (
        call :log "[*] *********** *******..."
        for %%p in (5555 5556 5557 5558 62001 62025 21503 7555) do (
            %ADB_EXE% connect 127.0.0.1:%%p >nul 2>nul
            for /f "tokens=1" %%a in ('%ADB_EXE% devices 2^>nul ^| findstr /v "List" ^| findstr /v "offline" ^| findstr "."') do (
                if not defined DEVICE set DEVICE=%%a
            )
            if defined DEVICE goto :conectado
        )
    )
)

:conectado
call :log "[*] ********** ***********..."
%ADB_EXE% wait-for-device
if %errorlevel% neq 0 (
    call :log "[ERROR] ******** *** *********."
    popd
    pause
    exit /b 1
)

for /f "tokens=*" %%a in ('%ADB_EXE% shell getprop ro.product.model 2^>nul') do set MODELO=%%a
call :log "[0K] ***********: %MODELO%"

:: Volta pra pasta original
popd

:: Caminho do destino
set DEST=/storage/emulated/0/Android/data/com.dts.freefiremax/files/localconfig.json

:: Envia
pushd "%ADB_DIR%"
call :log "[*] ******** *******..."
%ADB_EXE% push "%JSON_FILE%" "%DEST%"
if %errorlevel% neq 0 (
    call :log "[*] ********** *** /data/local/tmp..."
    %ADB_EXE% push "%JSON_FILE%" /data/local/tmp/localconfig.json
    %ADB_EXE% shell su -c "cp /data/local/tmp/localconfig.json '%DEST%'" >nul 2>nul
    if %errorlevel% neq 0 (
        %ADB_EXE% shell "cp /data/local/tmp/localconfig.json '%DEST%'" >nul 2>nul
    )
    if %errorlevel% neq 0 (
        %ADB_EXE% shell "cat /data/local/tmp/localconfig.json > '%DEST%'" >nul 2>nul
    )
    %ADB_EXE% shell rm /data/local/tmp/localconfig.json >nul 2>nul
    call :log "[0K] ********* *** ******!"
)

%ADB_EXE% shell chmod 644 "%DEST%" >nul 2>nul

:: Abre o Free Fire Max
call :log "[*] ****** **** **** ***..."
%ADB_EXE% shell monkey -p com.dts.freefiremax 1 >nul 2>nul
if %errorlevel% neq 0 (
    %ADB_EXE% shell am start -p com.dts.freefiremax >nul 2>nul
)

del "%JSON_FILE%" >nul 2>nul
popd
echo.
echo ========================================
echo        %ESC%[97mSGONX T2R TMM%ESC%[91m MENU%ESC%[0m - %ESC%[1;92mBYPASS CONCLUIDO!%ESC%[0m
echo ========================================
echo.
pause
goto :eof

:log
echo %*
goto :eof
