#!/bin/sh

set -e

# Add npm global directory to PATH
export PATH="/home/nextjs/.npm-global/bin:$PATH"

echo "Starting MetaMCP for Railway deployment..."

# Railway provides DATABASE_URL automatically
if [ -z "$DATABASE_URL" ]; then
    echo "❌ DATABASE_URL not provided by Railway"
    exit 1
fi

echo "✅ Using Railway managed PostgreSQL database"

# Function to run migrations
run_migrations() {
    echo "Running database migrations..."
    cd /app/apps/backend
    
    # Check if migrations need to be run
    if [ -d "drizzle" ] && [ "$(ls -A drizzle/*.sql 2>/dev/null)" ]; then
        echo "Found migration files, running migrations..."
        if pnpm exec drizzle-kit migrate; then
            echo "✅ Migrations completed successfully!"
        else
            echo "❌ Migration failed! Exiting..."
            exit 1
        fi
    else
        echo "No migrations found or directory empty"
    fi
    
    cd /app
}

# Run migrations
run_migrations

# Use Railway's PORT environment variable (defaults to 3000)
RAILWAY_PORT=${PORT:-3000}

echo "Starting MetaMCP services on port $RAILWAY_PORT..."

# Set application URLs for HTTPS
export APP_URL="https://${RAILWAY_STATIC_URL:-localhost:$RAILWAY_PORT}"
export NEXT_PUBLIC_APP_URL="https://${RAILWAY_STATIC_URL:-localhost:$RAILWAY_PORT}"

# Start backend server
cd /app/apps/backend
echo "Starting backend server on port $RAILWAY_PORT..."
PORT=$RAILWAY_PORT node dist/index.js &
BACKEND_PID=$!

# Wait for backend to start
sleep 5

# Check if backend is running
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo "❌ Backend server failed to start!"
    exit 1
fi

echo "✅ Backend server started successfully on port $RAILWAY_PORT"
echo "✅ HTTPS endpoints available at: https://${RAILWAY_STATIC_URL:-localhost:$RAILWAY_PORT}"

# Frontend will be served by the backend in production mode
echo "✅ Services ready for Railway deployment!"
echo "📡 API endpoints:"
echo "  - Health: https://${RAILWAY_STATIC_URL}/health"
echo "  - MetaMCP: https://${RAILWAY_STATIC_URL}/metamcp"  
echo "  - n8n Webhooks: https://${RAILWAY_STATIC_URL}/api/webhooks"
echo "  - LeetCode MCP: Available via /metamcp/stdio endpoint"

# Function to cleanup on exit
cleanup() {
    echo "Shutting down services..."
    kill $BACKEND_PID 2>/dev/null || true
    wait $BACKEND_PID 2>/dev/null || true
    echo "Services stopped"
}

# Trap signals for graceful shutdown
trap cleanup TERM INT

# Wait for backend process
wait $BACKEND_PID