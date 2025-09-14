#!/bin/bash

echo "🍴 Creating a fork of MetaMCP for Railway deployment..."

# Get current directory name
CURRENT_DIR=$(pwd)
PROJECT_NAME="metamcp-railway"

echo "Creating new repository directory: $PROJECT_NAME"

# Go up one directory level and create new project
cd ..
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# Initialize new git repository
git init
echo "✅ Initialized new git repository"

# Copy all files from original repo (excluding .git)
echo "📁 Copying files from original repository..."
rsync -av --exclude='.git' --exclude='node_modules' --exclude='.next' --exclude='dist' --exclude='.turbo' "$CURRENT_DIR/" ./

# Clean up unnecessary files for Railway deployment
rm -rf .turbo/
rm -rf apps/frontend/.next/
rm -rf apps/backend/dist/
rm -rf apps/backend/node_modules/
rm -rf apps/frontend/node_modules/
rm -rf packages/*/node_modules/
rm -rf node_modules/

echo "🧹 Cleaned up build artifacts and node_modules"

# Create Railway-specific .gitignore
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# Environment variables
.env*
!.env.example

# Build output
.next
out/
dist/
build/
.turbo/

# Runtime data
logs
*.log

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDEs
.vscode/
.idea/
*.swp
*.swo

# Railway
.railway/

# Local database
*.db
*.sqlite

# Temporary files
tmp/
temp/
EOF

# Create Railway-specific environment example
cat > .env.example << 'EOF'
# Required for Railway deployment
BETTER_AUTH_SECRET=your-super-secret-key-change-this-in-production

# Optional LeetCode configuration
LEETCODE_SESSION=optional-session-cookie-for-authenticated-requests
LEETCODE_SITE=global

# Railway automatically provides:
# DATABASE_URL=postgresql://...
# PORT=3000
# RAILWAY_STATIC_URL=https://your-app.railway.app
EOF

# Update README to point to Railway deployment guide
cat > README.md << 'EOF'
# 🚂 MetaMCP Railway Deployment

This is a Railway-optimized fork of MetaMCP with integrated LeetCode MCP server and n8n webhook support.

## 🚀 Quick Deploy

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template/new)

## 📚 Documentation

See [README-RAILWAY.md](./README-RAILWAY.md) for complete deployment instructions.

## 🔗 Features

- ✅ LeetCode MCP Server integration
- ✅ HTTPS endpoints
- ✅ n8n webhook support
- ✅ PostgreSQL database
- ✅ Authentication system
- ✅ Web interface for MCP management

## 🛠️ Quick Start

1. **Deploy to Railway:**
   - Click the deploy button above
   - Connect your GitHub account
   - Add PostgreSQL database
   - Set `BETTER_AUTH_SECRET` environment variable
   - Deploy!

2. **Test your deployment:**
   ```bash
   curl https://your-app.railway.app/health
   curl https://your-app.railway.app/api/webhooks/test-leetcode
   ```

3. **Use with n8n:**
   - Webhook URL: `https://your-app.railway.app/api/webhooks/leetcode`
   - See README-RAILWAY.md for complete examples

## 🎯 n8n Integration Examples

### Get Daily LeetCode Challenge
```bash
curl -X POST https://your-app.railway.app/api/webhooks/leetcode \
  -H "Content-Type: application/json" \
  -d '{"action": "get_daily_challenge"}'
```

### Search Problems
```bash
curl -X POST https://your-app.railway.app/api/webhooks/leetcode \
  -H "Content-Type: application/json" \
  -d '{
    "action": "search_problems",
    "parameters": {
      "difficulty": "EASY",
      "tags": ["array"],
      "limit": 5
    }
  }'
```

## 📞 Support

- 📖 Full documentation: [README-RAILWAY.md](./README-RAILWAY.md)
- 🐛 Issues: Create an issue on this repository
- 💬 Questions: Check the Railway deployment guide

---

**Ready for Railway deployment with LeetCode integration and n8n webhooks!** 🎉
EOF

# Add all files to git
git add .

# Create initial commit
git commit -m "Initial Railway deployment setup

- Added LeetCode MCP server integration
- Added n8n webhook endpoints
- Added Railway deployment configuration  
- Added HTTPS support
- Optimized for Railway platform deployment

Features:
- LeetCode daily challenges, problems, user profiles
- n8n webhook integration for automation
- PostgreSQL database with migrations
- Authentication system
- Web interface for MCP server management

Ready for Railway deployment!"

echo ""
echo "🎉 Successfully created Railway deployment repository!"
echo ""
echo "📍 New repository location: $(pwd)"
echo ""
echo "🔗 Next steps:"
echo "1. Create a new GitHub repository (e.g., 'metamcp-railway')"
echo "2. Add your remote origin:"
echo "   git remote add origin https://github.com/yourusername/metamcp-railway.git"
echo "3. Push to GitHub:"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "4. Deploy to Railway:"
echo "   - Go to railway.app"
echo "   - Click 'New Project'"
echo "   - Connect your new GitHub repository"
echo "   - Add PostgreSQL database"
echo "   - Set BETTER_AUTH_SECRET environment variable"
echo "   - Deploy!"
echo ""
echo "📚 See README-RAILWAY.md for detailed deployment instructions"
echo "🎯 Your Railway-ready MetaMCP with LeetCode and n8n integration is ready!"