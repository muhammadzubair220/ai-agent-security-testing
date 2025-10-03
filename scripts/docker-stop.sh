#!/bin/bash

# AI Agent Security Testing Framework - Docker Stop Script
# Script to stop and clean up Docker containers

set -e

echo "🛑 Stopping AI Agent Security Testing Framework"
echo "==============================================="

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running."
    exit 1
fi

echo "📋 Checking running containers..."
docker-compose ps

echo ""
echo "🛑 Stopping services..."
docker-compose down

echo ""
echo "🧹 Cleaning up unused containers and images..."
docker system prune -f

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "📊 Current Docker status:"
docker-compose ps