# ACE FlowSmith AI - MVP Quick Start Guide

> **AI-Powered ACE Flow Generation** - Transform natural language requirements into IBM App Connect Enterprise message flows in seconds.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.11+](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/downloads/)
[![React 18](https://img.shields.io/badge/react-18-blue.svg)](https://reactjs.org/)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Development](#development)
- [Testing](#testing)
- [Deployment](#deployment)
- [Documentation](#documentation)
- [Contributing](#contributing)

---

## 🎯 Overview

ACE FlowSmith AI is an intelligent agent that accelerates IBM App Connect Enterprise (ACE) development by automatically generating message flows and subflows from natural language requirements.

### The Problem
- New developers need 3-4 weeks to learn organization-specific ACE practices
- Manual flow development is time-consuming and error-prone
- Reusable subflows exist but are hard to discover
- Maintaining consistency across teams is challenging

### The Solution
- **AI-Powered Generation**: Create flows from simple text descriptions
- **Instant Results**: Generate flows in under 60 seconds
- **Best Practices Built-in**: Follows ACE standards automatically
- **Reusable Components**: 10+ pre-built subflows included

### MVP Goals
- ✅ Generate simple ACE flows (5-10 nodes)
- ✅ Visual flow preview
- ✅ Export to ACE XML format
- ✅ 50%+ time savings vs manual development
- ✅ 70%+ generation success rate

---

## ✨ Features

### Core Features (MVP)
- 📝 **Natural Language Input** - Describe your integration in plain English
- 🤖 **AI-Powered Generation** - GPT-4 analyzes and generates flows
- 👁️ **Visual Preview** - See your flow before exporting
- 📦 **Subflow Library** - 10 pre-built reusable components
- ✅ **Validation** - Ensures generated flows meet ACE standards
- 💾 **Export** - Download as .msgflow files ready for ACE Toolkit

### Included Subflows
1. StandardLogging - Request/response logging
2. ErrorHandling - Centralized error handling
3. DataValidation - JSON/XML validation
4. CustomerValidation - Customer data validation
5. JSONToXML - Data format transformation
6. XMLToJSON - Data format transformation
7. DatabaseRead - Database SELECT operations
8. DatabaseWrite - Database INSERT/UPDATE
9. RESTAPICall - Generic REST API calls
10. AuditTrail - Compliance audit logging

---

## 🔧 Prerequisites

### Required Software
- **Python 3.11+** - [Download](https://www.python.org/downloads/)
- **Node.js 18+** - [Download](https://nodejs.org/)
- **Docker & Docker Compose** - [Download](https://www.docker.com/products/docker-desktop)
- **Git** - [Download](https://git-scm.com/downloads)

### Required Accounts
- **OpenAI API Key** - [Get API Key](https://platform.openai.com/api-keys)
  - GPT-4 access required
  - Estimated cost: $5-10 for MVP testing

### Optional (Recommended)
- **IBM ACE Toolkit** - For testing generated flows
- **VS Code** - Recommended IDE
- **Postman** - For API testing

---

## 🚀 Quick Start

### Option 1: Docker (Recommended)

```bash
# 1. Clone the repository
git clone https://github.com/your-org/ace-flowsmith-mvp.git
cd ace-flowsmith-mvp

# 2. Create environment file
cp .env.example .env

# 3. Edit .env and add your OpenAI API key
nano .env
# Add: OPENAI_API_KEY=sk-your-key-here

# 4. Start all services
docker-compose up -d

# 5. Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:8000
# API Docs: http://localhost:8000/docs

# 6. View logs
docker-compose logs -f

# 7. Stop services
docker-compose down
```

### Option 2: Manual Setup

#### Backend Setup
```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Create .env file
cp .env.example .env
# Edit .env and add your OpenAI API key

# Initialize database
python scripts/init_db.py

# Seed with sample data
python scripts/seed_data.py

# Start development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Backend running at http://localhost:8000
```

#### Frontend Setup
```bash
# Open new terminal
cd frontend

# Install dependencies
npm install

# Create .env file
cp .env.example .env
# Edit if needed (default points to localhost:8000)

# Start development server
npm run dev

# Frontend running at http://localhost:3000
```

---

## 📁 Project Structure

```
ace-flowsmith-mvp/
├── README.md                          # This file
├── docker-compose.yml                 # Docker orchestration
├── .env.example                       # Environment template
├── .gitignore
│
├── backend/                           # Python FastAPI backend
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── app/
│   │   ├── main.py                   # FastAPI app entry point
│   │   ├── config.py                 # Configuration
│   │   ├── api/
│   │   │   ├── routes.py             # API endpoints
│   │   │   └── models.py             # Pydantic models
│   │   ├── services/
│   │   │   ├── parser.py             # Requirement parser
│   │   │   ├── generator.py          # Flow generator
│   │   │   ├── validator.py          # Flow validator
│   │   │   └── ai_service.py         # OpenAI integration
│   │   ├── templates/
│   │   │   ├── base_flow.xml         # Flow template
│   │   │   └── subflows/             # Subflow templates
│   │   ├── database/
│   │   │   ├── db.py                 # Database operations
│   │   │   └── models.py             # SQLAlchemy models
│   │   └── utils/
│   │       └── xml_builder.py        # XML generation
│   ├── tests/                        # Backend tests
│   └── scripts/                      # Utility scripts
│
├── frontend/                          # React TypeScript frontend
│   ├── Dockerfile
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   ├── src/
│   │   ├── App.tsx                   # Main app component
│   │   ├── main.tsx                  # Entry point
│   │   ├── components/
│   │   │   ├── RequirementForm.tsx   # Input form
│   │   │   ├── FlowViewer.tsx        # Flow visualization
│   │   │   ├── ValidationPanel.tsx   # Validation display
│   │   │   └── ExportDialog.tsx      # Export options
│   │   ├── services/
│   │   │   └── api.ts                # API client
│   │   ├── types/
│   │   │   └── models.ts             # TypeScript types
│   │   └── hooks/
│   │       └── useFlowGeneration.ts  # Custom hook
│   └── tests/                        # Frontend tests
│
└── docs/                              # Documentation
    ├── API.md                         # API documentation
    ├── USER_GUIDE.md                  # User guide
    └── DEVELOPMENT.md                 # Development guide
```

---

## 💻 Development

### Backend Development

#### Running Tests
```bash
cd backend

# Run all tests
python -m pytest

# Run with coverage
python -m pytest --cov=app --cov-report=html

# Run specific test file
python -m pytest tests/test_generator.py

# Run with verbose output
python -m pytest -v
```

#### Code Quality
```bash
# Format code
black app/

# Lint code
flake8 app/

# Type checking
mypy app/
```

#### Database Operations
```bash
# Reset database
python scripts/reset_db.py

# Seed sample data
python scripts/seed_data.py

# Backup database
cp flowsmith.db flowsmith.db.backup
```

### Frontend Development

#### Running Tests
```bash
cd frontend

# Run tests
npm test

# Run tests with coverage
npm test -- --coverage

# Run tests in watch mode
npm test -- --watch
```

#### Code Quality
```bash
# Lint code
npm run lint

# Format code
npm run format

# Type check
npm run type-check

# Build for production
npm run build
```

#### Component Development
```bash
# Start Storybook (if configured)
npm run storybook
```

---

## 🧪 Testing

### Test Coverage Goals
- Backend: 80%+ coverage
- Frontend: 70%+ coverage
- E2E: Critical user journeys

### Running All Tests
```bash
# Backend tests
cd backend && python -m pytest

# Frontend tests
cd frontend && npm test

# E2E tests (if configured)
npm run test:e2e
```

### Manual Testing Checklist

#### Happy Path
- [ ] Enter requirement and generate flow
- [ ] View generated flow visualization
- [ ] Validate flow (should pass)
- [ ] Download .msgflow file
- [ ] Import into ACE Toolkit (if available)

#### Error Cases
- [ ] Submit empty form (should show validation)
- [ ] Generate with invalid data (should handle gracefully)
- [ ] Test with network error (should show error message)
- [ ] Test with API rate limit (should queue/retry)

#### Edge Cases
- [ ] Very long requirement description
- [ ] Special characters in input
- [ ] Multiple concurrent generations
- [ ] Browser refresh during generation

---

## 🚢 Deployment

### Development Environment
```bash
docker-compose up -d
```

### Staging Environment
```bash
docker-compose -f docker-compose.staging.yml up -d
```

### Production Deployment (AWS EC2)

#### Prerequisites
- AWS EC2 instance (t3.medium or larger)
- Domain name configured
- SSL certificate (Let's Encrypt)

#### Deployment Steps
```bash
# 1. SSH into EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# 2. Install Docker
sudo apt-get update
sudo apt-get install -y docker.io docker-compose

# 3. Clone repository
git clone https://github.com/your-org/ace-flowsmith-mvp.git
cd ace-flowsmith-mvp

# 4. Configure environment
cp .env.example .env
nano .env  # Add production values

# 5. Start services
docker-compose -f docker-compose.prod.yml up -d

# 6. Setup Nginx reverse proxy
sudo apt-get install -y nginx
sudo nano /etc/nginx/sites-available/flowsmith
# Add configuration (see deployment guide)

# 7. Enable SSL
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com

# 8. Verify deployment
curl https://your-domain.com/health
```

### Monitoring
```bash
# View logs
docker-compose logs -f

# Check container status
docker-compose ps

# View resource usage
docker stats
```

---

## 📚 Documentation

### Available Documentation
- **[Architecture Design](./ACE_FlowSmith_AI_Architecture_Design.md)** - Complete system architecture
- **[MVP Implementation Plan](./ACE_FlowSmith_AI_MVP_Implementation_Plan.md)** - Detailed MVP plan
- **[API Documentation](http://localhost:8000/docs)** - Interactive API docs (when running)
- **[User Guide](./docs/USER_GUIDE.md)** - End-user documentation
- **[Development Guide](./docs/DEVELOPMENT.md)** - Developer documentation

### API Endpoints

#### Generate Flow
```bash
POST /api/generate
Content-Type: application/json

{
  "title": "Customer Order Integration",
  "description": "Receive orders via REST, validate, and send to SAP",
  "sourceSystem": "E-commerce Portal",
  "targetSystem": "SAP ERP",
  "protocol": "REST",
  "dataFormat": "JSON"
}
```

#### List Subflows
```bash
GET /api/subflows
```

#### Validate Flow
```bash
POST /api/validate
Content-Type: application/json

{
  "flow_xml": "<xml>...</xml>"
}
```

---

## 🎓 Usage Examples

### Example 1: Simple REST Integration
```
Title: Customer Order API
Description: Receive customer orders via REST API, validate customer data, 
and store in database
Source System: Mobile App
Target System: PostgreSQL Database
Protocol: REST
Data Format: JSON
```

**Generated Flow**:
- HTTPInput (REST endpoint)
- StandardLogging (log request)
- DataValidation (validate JSON)
- CustomerValidation (validate customer)
- DatabaseWrite (insert order)
- AuditTrail (log transaction)
- HTTPReply (send response)

### Example 2: Data Transformation
```
Title: SAP Integration
Description: Receive JSON data from web service, transform to XML, 
and send to SAP system
Source System: Web Service
Target System: SAP ERP
Protocol: REST
Data Format: JSON to XML
```

**Generated Flow**:
- HTTPInput (receive JSON)
- StandardLogging
- DataValidation
- JSONToXML (transform)
- RESTAPICall (call SAP)
- ErrorHandling
- HTTPReply

### Example 3: Database Integration
```
Title: Customer Lookup Service
Description: Receive customer ID via REST, query database, 
enrich with additional data, and return customer details
Source System: CRM System
Target System: Customer Database
Protocol: REST
Data Format: JSON
```

**Generated Flow**:
- HTTPInput
- StandardLogging
- DataValidation
- DatabaseRead (query customer)
- DataEnrichment (add details)
- AuditTrail
- HTTPReply

---

## 🐛 Troubleshooting

### Common Issues

#### Issue: "OpenAI API Error"
**Solution**: 
- Check API key in .env file
- Verify API key has GPT-4 access
- Check OpenAI account credits

#### Issue: "Database locked"
**Solution**:
```bash
# Stop all services
docker-compose down

# Remove database file
rm backend/flowsmith.db

# Restart services
docker-compose up -d
```

#### Issue: "Port already in use"
**Solution**:
```bash
# Find process using port
lsof -i :8000  # or :3000

# Kill process
kill -9 <PID>

# Or change port in docker-compose.yml
```

#### Issue: "Frontend can't connect to backend"
**Solution**:
- Check VITE_API_URL in frontend/.env
- Verify backend is running: `curl http://localhost:8000/health`
- Check CORS settings in backend/app/main.py

#### Issue: "Generated flow invalid"
**Solution**:
- Check validation errors in response
- Review generated XML in browser console
- Try simpler requirement first
- Report issue with requirement text

---

## 📊 Performance Benchmarks

### Target Metrics (MVP)
| Metric | Target | Current |
|--------|--------|---------|
| Flow Generation Time | < 60s | TBD |
| API Response Time | < 500ms | TBD |
| Concurrent Users | 10+ | TBD |
| Success Rate | > 70% | TBD |
| Uptime | > 95% | TBD |

### Load Testing
```bash
# Install locust
pip install locust

# Run load test
cd backend
locust -f tests/locustfile.py --host=http://localhost:8000
```

---

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Make changes
4. Run tests (`pytest` and `npm test`)
5. Commit changes (`git commit -m 'Add amazing feature'`)
6. Push to branch (`git push origin feature/amazing-feature`)
7. Open Pull Request

### Code Style
- **Backend**: Follow PEP 8, use Black formatter
- **Frontend**: Follow Airbnb style guide, use Prettier
- **Commits**: Use conventional commits format

### Pull Request Checklist
- [ ] Tests pass
- [ ] Code formatted
- [ ] Documentation updated
- [ ] No console errors
- [ ] Reviewed by peer

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Team

- **Project Lead**: [Your Name]
- **Tech Lead**: [Name]
- **Backend Developer**: [Name]
- **Frontend Developer**: [Name]
- **QA Engineer**: [Name]

---

## 📞 Support

### Getting Help
- **Documentation**: Check docs/ folder
- **Issues**: [GitHub Issues](https://github.com/your-org/ace-flowsmith-mvp/issues)
- **Email**: flowsmith-support@company.com
- **Slack**: #ace-flowsmith channel

### Reporting Bugs
Please include:
1. Steps to reproduce
2. Expected behavior
3. Actual behavior
4. Screenshots (if applicable)
5. Environment details (OS, browser, etc.)

---

## 🗺️ Roadmap

### MVP (Current) - Months 1-4
- [x] Core flow generation
- [x] Basic subflow library
- [x] Web UI
- [ ] Pilot with 10 users

### Phase 2 - Months 5-8
- [ ] ACE Toolkit plugin
- [ ] Advanced patterns
- [ ] BAR file generation
- [ ] Custom training

### Phase 3 - Months 9-12
- [ ] ACE Designer integration
- [ ] Multi-tenancy
- [ ] Enterprise features
- [ ] 100+ organizations

---

## 🎉 Quick Win: Generate Your First Flow

```bash
# 1. Start the application
docker-compose up -d

# 2. Open browser
open http://localhost:3000

# 3. Fill the form:
Title: Hello World Integration
Description: Receive HTTP request and return hello world message
Source: Web Browser
Target: HTTP Response
Protocol: REST
Format: JSON

# 4. Click "Generate Flow"

# 5. Download the .msgflow file

# 6. Success! You've generated your first ACE flow with AI! 🎊
```

---

## 📈 Success Metrics

Track these metrics during MVP:
- Number of flows generated
- Generation success rate
- Average generation time
- User satisfaction (1-5 rating)
- Time saved vs manual development
- Number of active users

---

**Ready to revolutionize ACE development? Let's get started! 🚀**

For detailed implementation guidance, see:
- [Architecture Design Document](./ACE_FlowSmith_AI_Architecture_Design.md)
- [MVP Implementation Plan](./ACE_FlowSmith_AI_MVP_Implementation_Plan.md)