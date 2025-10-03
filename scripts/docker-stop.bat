@echo off
REM AI Agent Security Testing Framework - Docker Stop Script (Windows)
REM Script to stop and clean up Docker containers

echo 🛑 Stopping AI Agent Security Testing Framework
echo ===============================================

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not running.
    pause
    exit /b 1
)

echo 📋 Checking running containers...
docker-compose ps

echo.
echo 🛑 Stopping services...
docker-compose down

echo.
echo 🧹 Cleaning up unused containers and images...
docker system prune -f

echo.
echo ✅ Cleanup complete!
echo.
echo 📊 Current Docker status:
docker-compose ps

pause