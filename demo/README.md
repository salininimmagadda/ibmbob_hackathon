# ACE FlowSmith AI - Demo Environment

Complete demo environment for showcasing ACE FlowSmith AI with working integration.

## 🎯 Demo Overview

This demo demonstrates the complete workflow:
1. **AI Generation** - Generate ACE flows from requirements
2. **Toolkit Integration** - Import and customize in ACE Toolkit
3. **Database Operations** - Working database with sample data
4. **Runtime Deployment** - Deploy and test on ACE runtime

## 📦 What's Included

```
demo/
├── docker-compose.yml              # All services orchestration
├── database/                       # PostgreSQL setup
│   ├── 01-schema.sql              # Database schema
│   └── 02-sample-data.sql         # Sample data (10 customers, 20 products)
├── flowsmith-ai/                   # AI web application
│   ├── frontend/                   # React UI
│   └── backend/                    # FastAPI backend
├── ace-workspace/                  # ACE Toolkit workspace
│   └── CustomerOrderApp/           # Sample application
├── deployment/                     # Deployment scripts
├── scripts/                        # Utility scripts
└── docs/                          # Demo documentation
```

## 🚀 Quick Start (5 Minutes)

### Prerequisites
- Docker & Docker Compose installed
- 8GB RAM available
- Ports available: 3000, 5432, 7800, 8000
- OpenAI API key (for AI generation)

### Step 1: Setup Environment

```bash
# Clone repository
git clone https://github.com/salininimmagadda/ibmbob_hackathon.git
cd ibmbob_hackathon/demo

# Create .env file
cat > .env << 'EOF'
OPENAI_API_KEY=your_openai_api_key_here
POSTGRES_USER=aceuser
POSTGRES_PASSWORD=acepassword
POSTGRES_DB=demo_db
EOF
```

### Step 2: Start All Services

```bash
# Start all services
docker-compose up -d

# Wait for services to be ready (30-60 seconds)
docker-compose ps

# Check logs
docker-compose logs -f
```

### Step 3: Verify Setup

```bash
# Check database
docker-compose exec postgres psql -U aceuser -d demo_db -c "SELECT COUNT(*) FROM customers;"

# Check FlowSmith AI
curl http://localhost:8000/health

# Check frontend
curl http://localhost:3000
```

### Step 4: Access Services

- **FlowSmith AI Web**: http://localhost:3000
- **FlowSmith API Docs**: http://localhost:8000/docs
- **Database**: localhost:5432 (aceuser/acepassword)
- **ACE Runtime**: localhost:7800

## 🎬 Demo Script (15 Minutes)

### Part 1: AI Flow Generation (3 min)

1. Open FlowSmith AI: http://localhost:3000

2. Enter requirement:
```
Title: Customer Order Processing
Description: Create REST API to receive customer orders, validate customer 
in database, check inventory availability, calculate pricing with tax, 
and insert order into database
Source System: E-commerce Portal
Target System: PostgreSQL Database
Protocol: REST
Data Format: JSON
```

3. Click "Generate Flow"

4. Review generated flow structure

5. Download generated files

### Part 2: Database Testing (2 min)

```bash
# Connect to database
docker-compose exec postgres psql -U aceuser -d demo_db

# View customers
SELECT * FROM customers LIMIT 5;

# View products
SELECT * FROM products LIMIT 5;

# View inventory
SELECT * FROM product_inventory_status;

# Exit
\q
```

### Part 3: Test Order Creation (3 min)

```bash
# Test successful order
curl -X POST http://localhost:7800/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "ORD999",
    "customerId": "CUST001",
    "items": [
      {
        "productId": "PROD001",
        "quantity": 1,
        "unitPrice": 1299.99
      }
    ],
    "totalAmount": 1299.99
  }'

# Verify in database
docker-compose exec postgres psql -U aceuser -d demo_db \
  -c "SELECT * FROM orders WHERE order_id = 'ORD999';"
```

### Part 4: View Analytics (2 min)

```bash
# Customer order summary
docker-compose exec postgres psql -U aceuser -d demo_db \
  -c "SELECT * FROM customer_order_summary;"

# Inventory status
docker-compose exec postgres psql -U aceuser -d demo_db \
  -c "SELECT * FROM product_inventory_status WHERE stock_status = 'LOW_STOCK';"

# Recent orders
docker-compose exec postgres psql -U aceuser -d demo_db \
  -c "SELECT order_id, customer_id, final_amount, status FROM orders ORDER BY order_date DESC LIMIT 5;"
```

### Part 5: Monitoring (2 min)

```bash
# View ACE runtime logs
docker-compose logs -f ace-runtime

# View database connections
docker-compose exec postgres psql -U aceuser -d demo_db \
  -c "SELECT * FROM pg_stat_activity WHERE datname = 'demo_db';"

# View audit trail
docker-compose exec postgres psql -U aceuser -d demo_db \
  -c "SELECT * FROM audit_log ORDER BY timestamp DESC LIMIT 10;"
```

## 🧪 Test Cases

### Test Case 1: Valid Order
```bash
curl -X POST http://localhost:7800/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "TEST001",
    "customerId": "CUST001",
    "items": [{"productId": "PROD002", "quantity": 2, "unitPrice": 29.99}],
    "totalAmount": 59.98
  }'

# Expected: 200 OK, order created
```

### Test Case 2: Invalid Customer
```bash
curl -X POST http://localhost:7800/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "TEST002",
    "customerId": "INVALID",
    "items": [{"productId": "PROD002", "quantity": 1, "unitPrice": 29.99}],
    "totalAmount": 29.99
  }'

# Expected: 400 Bad Request, customer not found
```

### Test Case 3: Insufficient Inventory
```bash
curl -X POST http://localhost:7800/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "TEST003",
    "customerId": "CUST001",
    "items": [{"productId": "PROD001", "quantity": 1000, "unitPrice": 1299.99}],
    "totalAmount": 1299990.00
  }'

# Expected: 400 Bad Request, insufficient inventory
```

## 📊 Sample Data

### Customers (10 total)
- CUST001 - John Smith (Credit: $15,000)
- CUST002 - Sarah Johnson (Credit: $20,000)
- CUST003 - Michael Brown (Credit: $10,000)
- ... 7 more

### Products (20 total)
- PROD001 - Laptop Pro 15" ($1,299.99)
- PROD002 - Wireless Mouse ($29.99)
- PROD003 - USB-C Hub ($49.99)
- ... 17 more

### Orders (5 existing)
- ORD001 - Delivered
- ORD002 - Shipped
- ORD003 - Processing
- ORD004 - Processing
- ORD005 - Pending

## 🛠️ Troubleshooting

### Services Not Starting
```bash
# Check Docker
docker --version
docker-compose --version

# Check ports
netstat -an | grep -E '3000|5432|7800|8000'

# Restart services
docker-compose down
docker-compose up -d
```

### Database Connection Issues
```bash
# Check database status
docker-compose exec postgres pg_isready

# View database logs
docker-compose logs postgres

# Recreate database
docker-compose down -v
docker-compose up -d
```

### ACE Runtime Issues
```bash
# Check ACE logs
docker-compose logs ace-runtime

# Restart ACE
docker-compose restart ace-runtime

# Check ACE status
docker-compose exec ace-runtime mqsilist
```

## 🔧 Customization

### Add More Sample Data
Edit `database/02-sample-data.sql` and restart:
```bash
docker-compose restart postgres
```

### Change Ports
Edit `docker-compose.yml` ports section:
```yaml
ports:
  - "3001:3000"  # Change frontend port
```

### Enable Debug Logging
```bash
# Set environment variable
export LOG_LEVEL=DEBUG

# Restart services
docker-compose up -d
```

## 📝 Demo Checklist

Before demo:
- [ ] All services running
- [ ] Database populated
- [ ] Test order creation works
- [ ] FlowSmith AI accessible
- [ ] Backup plan ready

During demo:
- [ ] Show AI generation
- [ ] Show database queries
- [ ] Create test order
- [ ] Show audit trail
- [ ] Answer questions

After demo:
- [ ] Collect feedback
- [ ] Note issues
- [ ] Plan improvements

## 🧹 Cleanup

```bash
# Stop all services
docker-compose down

# Remove volumes (deletes data)
docker-compose down -v

# Remove images
docker-compose down --rmi all
```

## 📚 Additional Resources

- [Full Architecture Document](../ACE_FlowSmith_AI_Architecture_Design.md)
- [MVP Implementation Plan](../ACE_FlowSmith_AI_MVP_Implementation_Plan.md)
- [ACE Toolkit Workflow](../ACE_Development_Workflow_Guide.md)
- [Integrated Solution](../ACE_FlowSmith_Integrated_Solution.md)

## 🆘 Support

For issues or questions:
- Check logs: `docker-compose logs`
- Review troubleshooting section above
- Contact: flowsmith-support@company.com

---

**Demo Version:** 1.0  
**Last Updated:** June 10, 2026  
**Status:** Ready for Demo 🎉