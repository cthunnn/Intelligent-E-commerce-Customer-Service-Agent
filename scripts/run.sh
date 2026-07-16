#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-docker}"

case "$MODE" in
    docker)
        echo "Starting with Docker Compose..."
        docker compose up -d
        echo "Services started. Frontend: http://localhost:3000, API: http://localhost:8000"
        ;;
    dev)
        echo "Starting in development mode..."
        echo "Starting backend..."
        cd backend
        source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null
        uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 &
        BACKEND_PID=$!
        cd ..

        echo "Starting frontend..."
        cd frontend
        npm run dev &
        FRONTEND_PID=$!
        cd ..

        trap "kill $BACKEND_PID $FRONTEND_PID 2>/dev/null" EXIT
        wait
        ;;
    *)
        echo "Usage: $0 {docker|dev}"
        exit 1
        ;;
esac
