# 🚂 MetaMCP Railway Deployment

Deploy MetaMCP with integrated LeetCode MCP server to Railway with HTTPS endpoints and n8n webhook support.

## 🚀 Quick Deploy to Railway

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/new)

### Prerequisites
- Railway account
- GitHub repository with this code

## 📋 Deployment Steps

### 1. Create Railway Project
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Create new project
railway new
```

### 2. Add PostgreSQL Database
```bash
# Add PostgreSQL service
railway add postgresql
```

### 3. Configure Environment Variables
Set these in Railway dashboard:

**Required:**
- `BETTER_AUTH_SECRET`: Your auth secret key (generate a strong random string)

**Optional:**
- `LEETCODE_SESSION`: LeetCode session cookie for authenticated requests
- `LEETCODE_SITE`: `global` (leetcode.com) or `cn` (leetcode.cn), default: `global`

### 4. Deploy
```bash
# Deploy to Railway
railway up
```

## 🌐 HTTPS Endpoints

Once deployed, your app will be available at: `https://your-app-name.railway.app`

### Available Endpoints:

#### 🏥 Health & Status
- `GET /health` - Service health check

#### 🔧 LeetCode MCP Server
- `POST /metamcp/stdio` - Direct MCP server access
- `GET /metamcp` - MCP server discovery

#### 🪝 n8n Webhooks (HTTPS)
- `POST /api/webhooks/leetcode` - LeetCode operations webhook
- `GET /api/webhooks/health` - Webhook health check
- `GET /api/webhooks/test-leetcode` - Test LeetCode MCP server
- `GET /api/webhooks/actions` - Available LeetCode actions

#### 🔐 Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration

## 🔗 n8n Integration

### Webhook Configuration

**Webhook URL:** `https://your-app-name.railway.app/api/webhooks/leetcode`

**Method:** POST

**Headers:**
```json
{
  "Content-Type": "application/json"
}
```

### Request Body Examples

#### Get Daily Challenge
```json
{
  "action": "get_daily_challenge"
}
```

#### Get Specific Problem
```json
{
  "action": "get_problem",
  "parameters": {
    "titleSlug": "two-sum"
  }
}
```

#### Search Problems
```json
{
  "action": "search_problems",
  "parameters": {
    "difficulty": "EASY",
    "tags": ["array", "hash-table"],
    "limit": 5
  }
}
```

#### Get User Profile
```json
{
  "action": "get_user_profile", 
  "parameters": {
    "username": "your-leetcode-username"
  }
}
```

### Response Format
```json
{
  "success": true,
  "action": "get_daily_challenge",
  "data": {
    "result": {
      "content": [
        {
          "type": "text",
          "text": "{\"date\":\"2025-09-14\",\"problem\":{...}}"
        }
      ]
    }
  },
  "timestamp": "2025-09-14T00:20:44.940Z"
}
```

## 🛠️ Available LeetCode Actions

| Action | Description | Required Parameters |
|--------|-------------|-------------------|
| `get_daily_challenge` | Get today's daily challenge | None |
| `get_problem` | Get problem details | `titleSlug` |
| `search_problems` | Search problems | None (optional: `difficulty`, `tags`, `limit`) |
| `get_user_profile` | Get user profile | `username` |
| `get_recent_submissions` | Get recent submissions | `username` (optional: `limit`) |
| `get_recent_ac_submissions` | Get accepted submissions | `username` (optional: `limit`) |
| `get_user_contest_ranking` | Get contest ranking | `username` |
| `list_problem_solutions` | List community solutions | `questionSlug` |
| `get_problem_solution` | Get solution details | `topicId` |

## 🧪 Testing Your Deployment

### Test Health Endpoint
```bash
curl https://your-app-name.railway.app/health
```

### Test LeetCode Integration
```bash
curl https://your-app-name.railway.app/api/webhooks/test-leetcode
```

### Test n8n Webhook
```bash
curl -X POST https://your-app-name.railway.app/api/webhooks/leetcode \
  -H "Content-Type: application/json" \
  -d '{
    "action": "get_daily_challenge"
  }'
```

## 🔧 Environment Configuration

### Railway Environment Variables

The app automatically uses Railway's provided environment variables:

- `DATABASE_URL` - Provided by Railway PostgreSQL
- `PORT` - Provided by Railway (usually 3000)
- `RAILWAY_STATIC_URL` - Your app's public URL

### Custom Configuration

Add these in Railway dashboard under Variables:

```env
BETTER_AUTH_SECRET=your-super-secret-auth-key-here
LEETCODE_SESSION=optional-leetcode-session-cookie
LEETCODE_SITE=global
```

## 📊 Monitoring & Logs

View logs in Railway dashboard:
```bash
# Or via CLI
railway logs
```

## 🔄 Updates & Redeploys

```bash
# Redeploy after code changes
railway up

# Or enable auto-deploy from GitHub in Railway dashboard
```

## 🎯 n8n Workflow Examples

### Example 1: Daily LeetCode Challenge Notification
1. **Trigger:** Schedule (daily at 9 AM)
2. **HTTP Request:** POST to `/api/webhooks/leetcode`
   - Body: `{"action": "get_daily_challenge"}`
3. **Process:** Extract problem details
4. **Action:** Send to Slack/Discord/Email

### Example 2: User Progress Tracking
1. **Trigger:** Schedule (weekly)
2. **HTTP Request:** POST to `/api/webhooks/leetcode`
   - Body: `{"action": "get_user_profile", "parameters": {"username": "your-username"}}`
3. **Process:** Compare with previous stats
4. **Action:** Generate progress report

### Example 3: Problem Search & Study Plan
1. **Trigger:** Manual/Webhook
2. **HTTP Request:** POST to `/api/webhooks/leetcode`
   - Body: `{"action": "search_problems", "parameters": {"difficulty": "MEDIUM", "tags": ["dynamic-programming"], "limit": 10}}`
3. **Process:** Create study schedule
4. **Action:** Add to calendar/task manager

## 🛡️ Security Notes

- All endpoints use HTTPS by default on Railway
- Authentication required for admin functions
- Rate limiting implemented for webhook endpoints
- Environment variables securely managed by Railway

## 📞 Support

If you encounter issues:
1. Check Railway logs: `railway logs`
2. Test webhook health: `GET /api/webhooks/health`
3. Verify LeetCode MCP: `GET /api/webhooks/test-leetcode`

---

**🎉 Your MetaMCP with LeetCode integration is now ready for n8n automation workflows!**