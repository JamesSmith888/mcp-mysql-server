@echo off
REM Project Launcher for Windows with Auto JRE Download
REM Requires PowerShell for downloading

setlocal EnableDelayedExpansion

REM Configuration
set JAVA_VERSION=21
set JRE_VENDOR=eclipse-temurin
set PROJECT_DIR=%~dp0

REM Colors (limited support in CMD)
set INFO=[INFO]
set SUCCESS=[SUCCESS]
set WARN=[WARN]
set ERROR=[ERROR]

echo %INFO% Starting project launcher for Windows...
echo %INFO% Required Java version: %JAVA_VERSION%

REM Detect architecture
set ARCH=x64
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" set ARCH=aarch64
if "%PROCESSOR_ARCHITEW6432%"=="ARM64" set ARCH=aarch64

echo %INFO% Platform detected: windows-%ARCH%

REM Set JRE home directory
set JRE_HOME=%USERPROFILE%\.jres\%JRE_VENDOR%-jre-%JAVA_VERSION%-windows-%ARCH%

echo %INFO% JRE home: %JRE_HOME%

REM Check if JRE exists and works
if exist "%JRE_HOME%\bin\java.exe" (
    "%JRE_HOME%\bin\java.exe" -version 2>nul | findstr "openjdk version \"%JAVA_VERSION%" >nul
    if !errorlevel! equ 0 (
        echo %SUCCESS% Using existing JRE at %JRE_HOME%
        goto :run_maven
    ) else (
        echo %WARN% Existing JRE version mismatch, will re-download
        rmdir /s /q "%JRE_HOME%" 2>nul
    )
)

echo %INFO% Downloading JRE %JAVA_VERSION% for windows-%ARCH%...

REM Create JRE directory
if not exist "%JRE_HOME%" mkdir "%JRE_HOME%"

REM Download URL
set DOWNLOAD_URL=https://api.adoptium.net/v3/binary/latest/%JAVA_VERSION%/ga/windows/%ARCH%/jre/hotspot/normal/%JRE_VENDOR%

REM Create temp directory
set TEMP_DIR=%TEMP%\jre_download_%RANDOM%
mkdir "%TEMP_DIR%"

echo %INFO% Downloading from: %DOWNLOAD_URL%

REM Download using PowerShell
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%TEMP_DIR%\jre.zip' -UseBasicParsing}"

if !errorlevel! neq 0 (
    echo %ERROR% Failed to download JRE
    rmdir /s /q "%TEMP_DIR%" 2>nul
    exit /b 1
)

echo %INFO% Extracting JRE to %JRE_HOME%...

REM Extract using PowerShell
powershell -Command "& {Expand-Archive -Path '%TEMP_DIR%\jre.zip' -DestinationPath '%TEMP_DIR%' -Force}"

REM Find extracted directory and move contents
for /d %%i in ("%TEMP_DIR%\*jre*" "%TEMP_DIR%\*jdk*") do (
    if exist "%%i" (
        xcopy "%%i\*" "%JRE_HOME%\" /s /e /i /q
        goto :extract_done
    )
)

:extract_done
REM Cleanup
rmdir /s /q "%TEMP_DIR%" 2>nul

REM Verify installation
if not exist "%JRE_HOME%\bin\java.exe" (
    echo %ERROR% JRE installation failed: java.exe not found
    exit /b 1
)

echo %SUCCESS% JRE %JAVA_VERSION% installed successfully

:run_maven
REM Set JAVA_HOME for Maven
set JAVA_HOME=%JRE_HOME%

REM Add Java to PATH
set PATH=%JRE_HOME%\bin;%PATH%

REM Display Java version
echo %INFO% Java version:
"%JRE_HOME%\bin\java.exe" -version

echo %SUCCESS% Java environment setup complete

REM Check if mvnw.cmd exists
if not exist "%PROJECT_DIR%mvnw.cmd" (
    echo %ERROR% Maven wrapper script not found: %PROJECT_DIR%mvnw.cmd
    exit /b 1
)

REM Run Maven with all arguments
echo %INFO% Executing: %PROJECT_DIR%mvnw.cmd %*
echo %INFO% ----------------------------------------

call "%PROJECT_DIR%mvnw.cmd" %*
