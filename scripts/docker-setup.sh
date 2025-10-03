#!/bin/bash

# AI Agent Security Testing Framework - Docker Setup Script
# This script sets up the Docker environment for the security testing framework

set -e

echo "🐳 AI Agent Security Testing Framework - Docker Setup"
echo "=================================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available. Please install Docker Compose."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "✅ Created .env file. You can modify it if needed."
fi

# Create evidence directory
echo "📁 Creating evidence directories..."
mkdir -p evidence/{screenshots,logs,reports,videos}
echo "✅ Evidence directories created."

# Build the Docker image
echo "🔨 Building Docker image..."
docker build -t ai-security-testing .
echo "✅ Docker image built successfully."

# Function to check if port is available
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 1
    else
        return 0
    fi
}

# Check if port 8080 is available
if ! check_port 8080; then
    echo "⚠️  Port 8080 is already in use. The container will still start but may conflict."
    echo "   You can modify the port in docker-compose.yml if needed."
fi

echo ""
echo "🚀 Setup complete! You can now run the framework using:"
echo ""
echo "   # Start the service:"
echo "   docker-compose up -d"
echo ""
echo "   # View logs:"
echo "   docker-compose logs -f"
echo ""
echo "   # Stop the service:"
echo "   docker-compose down"
echo ""
echo "   # Start with nginx reverse proxy:"
echo "   docker-compose --profile production up -d"
echo ""
echo "📍 The framework will be available at:"
echo "   http://localhost:8080 (direct access)"
echo "   http://localhost (with nginx profile)"
echo ""
echo "📊 Attack variations will be available at:"
echo "   http://localhost:8080/attack/1 (Social Media Comment Injection)"
echo "   http://localhost:8080/attack/2 (Review Site Data Exfiltration)"