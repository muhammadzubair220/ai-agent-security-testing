@echo off
REM AI Agent Security Testing Framework - Docker Run Script (Windows)
REM Quick script to run the framework in Docker

setlocal enabledelayedexpansion

echo 🚀 Starting AI Agent Security Testing Framework
echo ==============================================

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

REM Parse command line arguments
set DETACHED=false
set PRODUCTION=false
set CUSTOM_PORT=

:parse_args
if "%~1"=="" goto end_parse
if "%~1"=="-d" set DETACHED=true
if "%~1"=="--detached" set DETACHED=true
if "%~1"=="-p" set PRODUCTION=true
if "%~1"=="--production" set PRODUCTION=true
if "%~1"=="--port" (
    set CUSTOM_PORT=%~2
    shift
)
if "%~1"=="-h" goto show_help
if "%~1"=="--help" goto show_help
shift
goto parse_args

:show_help
echo Usage: %0 [OPTIONS]
echo.
echo Options:
echo   -d, --detached     Run in detached mode
echo   -p, --production   Run with nginx reverse proxy
echo   --port PORT        Use custom port (default: 8080)
echo   -h, --help         Show this help message
exit /b 0

:end_parse

REM Check for port conflicts and find available port
if not "%CUSTOM_PORT%"=="" (
    set EXTERNAL_PORT=%CUSTOM_PORT%
) else (
    REM Try to find an available port starting from 8080
    set EXTERNAL_PORT=8080
    call :find_available_port
)

REM Set environment variable for docker-compose
set EXTERNAL_PORT=%EXTERNAL_PORT%

REM Build compose command
set COMPOSE_CMD=docker-compose
if "%PRODUCTION%"=="true" (
    set COMPOSE_CMD=!COMPOSE_CMD! --profile production
)

set COMPOSE_CMD=!COMPOSE_CMD! up
if "%DETACHED%"=="true" (
    set COMPOSE_CMD=!COMPOSE_CMD! -d
)

REM Run the command
echo 🐳 Running: !COMPOSE_CMD!
!COMPOSE_CMD!

if "%DETACHED%"=="true" (
    echo.
    echo ✅ Framework started in detached mode!
    echo.
    echo 📍 Access the framework at:
    if "%PRODUCTION%"=="true" (
        echo    http://localhost (nginx reverse proxy)
    )
    echo    http://localhost:%EXTERNAL_PORT% (direct access)
    echo.
    echo 📊 Attack variations:
    echo    http://localhost:%EXTERNAL_PORT%/attack/1 (Social Media Comment Injection)
    echo    http://localhost:%EXTERNAL_PORT%/attack/2 (Review Site Data Exfiltration)
    echo.
    echo 📋 Useful commands:
    echo    docker-compose logs -f          # View logs
    echo    docker-compose down             # Stop services
    echo    docker-compose ps               # Check status
    pause
) else (
    echo.
    echo 🛑 Framework stopped. Use 'docker-compose down' to clean up if needed.
    pause
)

goto :eof

:find_available_port
REM Simple port availability check for Windows
netstat -an | findstr ":%EXTERNAL_PORT% " >nul 2>&1
if errorlevel 1 (
    REM Port is available
    goto :eof
) else (
    REM Port is in use, try next one
    set /a EXTERNAL_PORT+=1
    if %EXTERNAL_PORT% lss 9000 (
        call :find_available_port
    ) else (
        echo ⚠️ Could not find available port between 8080-8999
        set EXTERNAL_PORT=8080
    )
)
goto :eof