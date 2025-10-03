@echo off
REM Quick start script that handles port conflicts automatically

echo 🚀 AI Agent Security Testing Framework - Quick Start
echo ===================================================

REM Stop any existing containers first
echo 🛑 Stopping any existing containers...
docker-compose down >nul 2>&1

REM Find available port
set EXTERNAL_PORT=8081
echo 🔍 Using port %EXTERNAL_PORT% to avoid conflicts...

REM Start with custom port
echo 🐳 Starting framework on port %EXTERNAL_PORT%...
set EXTERNAL_PORT=%EXTERNAL_PORT%
docker-compose up -d

if errorlevel 1 (
    echo ❌ Failed to start. Trying port 8082...
    set EXTERNAL_PORT=8082
    docker-compose up -d
)

echo.
echo ✅ Framework started successfully!
echo.
echo 📍 Access the framework at:
echo    http://localhost:%EXTERNAL_PORT%
echo.
echo 📊 Attack variations:
echo    http://localhost:%EXTERNAL_PORT%/attack/1 (Social Media Comment Injection)
echo    http://localhost:%EXTERNAL_PORT%/attack/2 (Review Site Data Exfiltration)
echo.
echo 📋 To stop the framework:
echo    scripts\docker-stop.bat
echo.
pause