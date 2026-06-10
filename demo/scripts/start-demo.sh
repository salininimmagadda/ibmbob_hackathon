#!/bin/bash
# Start ACE FlowSmith AI Demo Environment

set -e

echo "========================================="
echo "  ACE FlowSmith AI - Demo Startup"
echo "========================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running"
    echo "Please start Docker and try again"
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  Warning: .env file not found"
    echo "Creating .env file from template..."
    cat > .env << 'EOF'
OPENAI_API_KEY=your_openai_api_key_here
POSTGRES_USER=aceuser
POSTGRES_PASSWORD=acepassword
POSTGRES_DB=demo_db
EOF
    echo "✓ .env file created"
    echo "⚠️  Please edit .env and add your OpenAI API key"
    echo ""
fi

# Navigate to demo directory
cd "$(dirname "$0")/.."

echo "1. Starting Docker services..."
docker-compose up -d

echo ""
echo "2. Waiting for services to be ready..."
sleep 10

# Check PostgreSQL
echo "   Checking PostgreSQL..."
until docker-compose exec -T postgres pg_isready -U aceuser > /dev/null 2>&1; do
    echo "   Waiting for PostgreSQL..."
    sleep 2
done
echo "   ✓ PostgreSQL is ready"

# Check FlowSmith Backend
echo "   Checking FlowSmith Backend..."
until curl -s http://localhost:8000/health > /dev/null 2>&1; do
    echo "   Waiting for FlowSmith Backend..."
    sleep 2
done
echo "   ✓ FlowSmith Backend is ready"

# Check FlowSmith Frontend
echo "   Checking FlowSmith Frontend..."
until curl -s http://localhost:3000 > /dev/null 2>&1; do
    echo "   Waiting for FlowSmith Frontend..."
    sleep 2
done
echo "   ✓ FlowSmith Frontend is ready"

echo ""
echo "3. Verifying database setup..."
CUSTOMER_COUNT=$(docker-compose exec -T postgres psql -U aceuser -d demo_db -t -c "SELECT COUNT(*) FROM customers;" 2>/dev/null | tr -d ' ')
PRODUCT_COUNT=$(docker-compose exec -T postgres psql -U aceuser -d demo_db -t -c "SELECT COUNT(*) FROM products;" 2>/dev/null | tr -d ' ')

echo "   ✓ Customers: $CUSTOMER_COUNT"
echo "   ✓ Products: $PRODUCT_COUNT"

echo ""
echo "========================================="
echo "  ✓ Demo Environment Ready!"
echo "========================================="
echo ""
echo "Access Points:"
echo "  • FlowSmith AI:  http://localhost:3000"
echo "  • API Docs:      http://localhost:8000/docs"
echo "  • Database:      localhost:5432"
echo "  • ACE Runtime:   localhost:7800"
echo ""
echo "Quick Commands:"
echo "  • View logs:     docker-compose logs -f"
echo "  • Stop demo:     ./scripts/stop-demo.sh"
echo "  • Reset demo:    ./scripts/reset-demo.sh"
echo ""
echo "Demo Script: See demo/README.md for 15-minute demo"
echo "========================================="

# Made with Bob
