#!/bin/bash
# Stop ACE FlowSmith AI Demo Environment

echo "Stopping demo environment..."
cd "$(dirname "$0")/.."
docker-compose down
echo "✓ Demo stopped"
