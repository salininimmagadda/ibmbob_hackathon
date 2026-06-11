#!/bin/bash
# Start Simple Demo (No OpenAI Required)

echo "========================================="
echo "  ACE FlowSmith AI - Simple Demo"
echo "  (No OpenAI API Key Required)"
echo "========================================="
echo ""

cd "$(dirname "$0")/.."

echo "Starting database and pgAdmin..."
docker-compose -f docker-compose-simple.yml up -d

echo ""
echo "Waiting for services..."
sleep 15

echo ""
echo "========================================="
echo "  ✓ Demo Ready!"
echo "========================================="
echo ""
echo "Access Points:"
echo "  • pgAdmin:  http://localhost:5050"
echo "    Email:    admin@demo.com"
echo "    Password: admin"
echo ""
echo "  • Database: localhost:5432"
echo "    User:     aceuser"
echo "    Password: acepassword"
echo "    Database: demo_db"
echo ""
echo "Demo Guide: See DEMO_WITHOUT_OPENAI.md"
echo "========================================="
