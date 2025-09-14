#!/bin/bash

echo "🚂 Setting up MetaMCP for Railway deployment..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
fi

# Create .gitignore for Railway deployment
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

# dotenv environment variables file
.env*
!.env.example

# parcel-bundler cache (https://parceljs.org/)
.cache
.parcel-cache

# Next.js build output
.next
out/

# Production build
dist/
build/

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

echo "✅ Railway repository setup complete!"
echo ""
echo "🚀 Next steps:"
echo "1. Create a new GitHub repository"
echo "2. Add your files:"
echo "   git add ."
echo "   git commit -m 'Initial Railway deployment setup'"
echo "   git remote add origin https://github.com/yourusername/your-repo.git"
echo "   git push -u origin main"
echo ""
echo "3. Deploy to Railway:"
echo "   - Go to railway.app"
echo "   - Click 'New Project'"
echo "   - Connect your GitHub repository"
echo "   - Add PostgreSQL database"
echo "   - Set environment variables"
echo "   - Deploy!"
echo ""
echo "📚 See README-RAILWAY.md for detailed instructions"