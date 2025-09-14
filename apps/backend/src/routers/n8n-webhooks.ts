import express from "express";
import { z } from "zod";

const router = express.Router();

// Middleware for JSON parsing (specific to webhook routes)
router.use(express.json({ limit: "10mb" }));

// Schema for n8n LeetCode webhook requests
const LeetCodeWebhookSchema = z.object({
  action: z.enum([
    "get_daily_challenge",
    "get_problem", 
    "search_problems",
    "get_user_profile",
    "get_recent_submissions",
    "get_recent_ac_submissions",
    "get_user_contest_ranking",
    "list_problem_solutions",
    "get_problem_solution"
  ]),
  parameters: z.record(z.any()).optional(),
});

// Helper function to call LeetCode MCP server
async function callLeetCodeMCP(action: string, parameters: any = {}) {
  const { spawn } = await import("child_process");
  
  return new Promise((resolve, reject) => {
    const process = spawn("npx", ["@jinzcdev/leetcode-mcp-server"], {
      env: { 
        ...process.env, 
        PATH: "/home/nextjs/.npm-global/bin:" + process.env.PATH 
      }
    });
    
    let stdout = "";
    let stderr = "";
    
    // Send MCP request
    const request = {
      jsonrpc: "2.0",
      id: 1,
      method: "tools/call",
      params: {
        name: action,
        arguments: parameters
      }
    };
    
    process.stdin.write(JSON.stringify(request) + "\n");
    process.stdin.end();
    
    process.stdout.on("data", (data) => {
      stdout += data.toString();
    });
    
    process.stderr.on("data", (data) => {
      stderr += data.toString();
    });
    
    process.on("close", (code) => {
      if (code === 0) {
        try {
          const response = JSON.parse(stdout);
          resolve(response);
        } catch (error) {
          reject(new Error(`Failed to parse MCP response: ${error}`));
        }
      } else {
        reject(new Error(`LeetCode MCP server failed with code ${code}: ${stderr}`));
      }
    });
    
    // Timeout after 30 seconds
    setTimeout(() => {
      process.kill();
      reject(new Error("LeetCode MCP server timeout"));
    }, 30000);
  });
}

// Main n8n webhook endpoint for LeetCode operations
router.post("/leetcode", async (req, res) => {
  try {
    console.log("📥 n8n webhook received:", JSON.stringify(req.body, null, 2));
    
    const { action, parameters } = LeetCodeWebhookSchema.parse(req.body);
    
    // Call LeetCode MCP server
    const result = await callLeetCodeMCP(action, parameters || {});
    
    console.log("✅ LeetCode MCP response:", JSON.stringify(result, null, 2));
    
    res.json({
      success: true,
      action,
      data: result,
      timestamp: new Date().toISOString()
    });
    
  } catch (error: any) {
    console.error("❌ n8n webhook error:", error);
    
    res.status(400).json({
      success: false,
      error: error.message || "Unknown error",
      timestamp: new Date().toISOString()
    });
  }
});

// Health check endpoint for n8n webhooks
router.get("/health", (req, res) => {
  res.json({
    status: "healthy",
    service: "n8n-webhooks",
    timestamp: new Date().toISOString(),
    endpoints: {
      leetcode: "POST /api/webhooks/leetcode"
    }
  });
});

// Test endpoint to verify LeetCode MCP server is working
router.get("/test-leetcode", async (req, res) => {
  try {
    const result = await callLeetCodeMCP("get_daily_challenge");
    
    res.json({
      success: true,
      message: "LeetCode MCP server is working",
      dailyChallenge: result,
      timestamp: new Date().toISOString()
    });
    
  } catch (error: any) {
    res.status(500).json({
      success: false,
      error: error.message,
      message: "LeetCode MCP server is not working",
      timestamp: new Date().toISOString()
    });
  }
});

// Get available LeetCode actions
router.get("/actions", (req, res) => {
  res.json({
    actions: [
      {
        name: "get_daily_challenge",
        description: "Get today's LeetCode daily challenge",
        parameters: {}
      },
      {
        name: "get_problem",
        description: "Get specific LeetCode problem details",
        parameters: { titleSlug: "string (required)" }
      },
      {
        name: "search_problems", 
        description: "Search LeetCode problems",
        parameters: {
          difficulty: "EASY|MEDIUM|HARD (optional)",
          tags: "array of strings (optional)",
          limit: "number (optional)"
        }
      },
      {
        name: "get_user_profile",
        description: "Get LeetCode user profile",
        parameters: { username: "string (required)" }
      },
      {
        name: "get_recent_submissions",
        description: "Get user's recent submissions",
        parameters: { 
          username: "string (required)",
          limit: "number (optional)"
        }
      }
    ],
    timestamp: new Date().toISOString()
  });
});

export default router;