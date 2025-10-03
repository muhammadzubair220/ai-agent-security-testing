#!/bin/bash

# AI Agent Security Testing Framework - Docker Run Script
# Quick script to run the framework in Docker

set -e

echo "🚀 Starting AI Agent Security Testing Framework"
echo "=============================================="

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Parse command line arguments
DETACHED=false
PRODUCTION=false
PORT=8080

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--detached)
            DETACHED=true
            shift
            ;;
        -p|--production)
            PRODUCTION=true
            shift
            ;;
        --port)
            PORT="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -d, --detached     Run in detached mode"
            echo "  -p, --production   Run with nginx reverse proxy"
            echo "  --port PORT        Use custom port (default: 8080)"
            echo "  -h, --help         Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Update port in docker-compose if different from default
if [ "$PORT" != "8080" ]; then
    echo "📝 Using custom port: $PORT"
    export SERVER_PORT=$PORT
fi

# Build compose command
COMPOSE_CMD="docker-compose"
if [ "$PRODUCTION" = true ]; then
    COMPOSE_CMD="$COMPOSE_CMD --profile production"
fi

COMPOSE_CMD="$COMPOSE_CMD up"
if [ "$DETACHED" = true ]; then
    COMPOSE_CMD="$COMPOSE_CMD -d"
fi

# Run the command
echo "🐳 Running: $COMPOSE_CMD"
eval $COMPOSE_CMD

if [ "$DETACHED" = true ]; then
    echo ""
    echo "✅ Framework started in detached mode!"
    echo ""
    echo "📍 Access the framework at:"
    if [ "$PRODUCTION" = true ]; then
        echo "   http://localhost (nginx reverse proxy)"
    fi
    echo "   http://localhost:$PORT (direct access)"
    echo ""
    echo "📊 Attack variations:"
    echo "   http://localhost:$PORT/attack/1 (Social Media Comment Injection)"
    echo "   http://localhost:$PORT/attack/2 (Review Site Data Exfiltration)"
    echo ""
    echo "📋 Useful commands:"
    echo "   docker-compose logs -f          # View logs"
    echo "   docker-compose down             # Stop services"
    echo "   docker-compose ps               # Check status"
else
    echo ""
    echo "🛑 Framework stopped. Use 'docker-compose down' to clean up if needed."
fi