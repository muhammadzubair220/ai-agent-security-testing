@echo off
REM AI Agent Security Testing Framework - Docker Setup Script (Windows)
REM This script sets up the Docker environment for the security testing framework

echo 🐳 AI Agent Security Testing Framework - Docker Setup
echo ==================================================

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not installed. Please install Docker Desktop first.
    echo Visit: https://docs.docker.com/desktop/windows/
    pause
    exit /b 1
)

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

REM Create .env file if it doesn't exist
if not exist .env (
    echo 📝 Creating .env file from template...
    copy .env.example .env >nul
    echo ✅ Created .env file. You can modify it if needed.
)

REM Create evidence directories
echo 📁 Creating evidence directories...
if not exist evidence mkdir evidence
if not exist evidence\screenshots mkdir evidence\screenshots
if not exist evidence\logs mkdir evidence\logs
if not exist evidence\reports mkdir evidence\reports
if not exist evidence\videos mkdir evidence\videos
echo ✅ Evidence directories created.

REM Build the Docker image
echo 🔨 Building Docker image...
docker build -t ai-security-testing .
if errorlevel 1 (
    echo ❌ Failed to build Docker image.
    pause
    exit /b 1
)
echo ✅ Docker image built successfully.

echo.
echo 🚀 Setup complete! You can now run the framework using:
echo.
echo    # Start the service:
echo    docker-compose up -d
echo.
echo    # View logs:
echo    docker-compose logs -f
echo.
echo    # Stop the service:
echo    docker-compose down
echo.
echo    # Or use the provided batch file:
echo    scripts\docker-run.bat
echo.
echo 📍 The framework will be available at:
echo    http://localhost:8080
echo.
echo 📊 Attack variations will be available at:
echo    http://localhost:8080/attack/1 (Social Media Comment Injection)
echo    http://localhost:8080/attack/2 (Review Site Data Exfiltration)
echo.
pause