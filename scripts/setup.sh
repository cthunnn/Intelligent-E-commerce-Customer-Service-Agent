#!/usr/bin/env bash
set -euo pipefail

echo "=== E-Commerce Customer Service Setup ==="

# Check prerequisites
command -v python3 >/dev/null 2>&1 || { echo "Python 3 is required"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "Node.js is required"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "Docker is required"; exit 1; }

# Copy environment file
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env from .env.example. Please edit .env with your configuration."
fi

# Backend setup
echo "Setting up backend..."
cd backend
python3 -m venv venv
source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null
pip install --upgrade pip --break-system-packages 2>/dev/null || pip install --upgrade pip
pip install -r requirements.txt --break-system-packages 2>/dev/null || pip install -r requirements.txt
deactivate
cd ..

# Frontend setup
echo "Setting up frontend..."
cd frontend
npm install
cd ..

echo ""
echo "Setup complete!"
echo ""
echo "To start development:"
echo "  Backend: cd backend && source venv/bin/activate && uvicorn app.main:app --reload"
echo "  Frontend: cd frontend && npm run dev"
echo ""
echo "Or use Docker: docker compose up -d"
