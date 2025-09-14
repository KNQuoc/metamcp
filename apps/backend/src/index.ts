import express from "express";

import { auth } from "./auth";
import { initializeIdleServers } from "./lib/startup";
import mcpProxyRouter from "./routers/mcp-proxy";
import n8nWebhooksRouter from "./routers/n8n-webhooks";
import oauthRouter from "./routers/oauth";
import publicEndpointsRouter from "./routers/public-metamcp";
import trpcRouter from "./routers/trpc";

const app = express();

// Global JSON middleware for non-proxy routes
app.use((req, res, next) => {
  if (req.path.startsWith("/mcp-proxy/") || req.path.startsWith("/metamcp/")) {
    // Skip JSON parsing for all MCP proxy routes and public endpoints to allow raw stream access
    next();
  } else {
    express.json({ limit: "50mb" })(req, res, next);
  }
});

// Mount OAuth metadata endpoints at root level for .well-known discovery
app.use(oauthRouter);

// Mount better-auth routes by calling auth API directly
app.use(async (req, res, next) => {
  if (req.path.startsWith("/api/auth")) {
    try {
      // Create a web Request object from Express request
      const url = new URL(req.url, `http://${req.headers.host}`);
      const headers = new Headers();

      // Copy headers from Express request
      Object.entries(req.headers).forEach(([key, value]) => {
        if (value) {
          headers.set(key, Array.isArray(value) ? value[0] : value);
        }
      });

      // Create Request object
      const request = new Request(url.toString(), {
        method: req.method,
        headers,
        body:
          req.method !== "GET" && req.method !== "HEAD"
            ? JSON.stringify(req.body)
            : undefined,
      });

      // Call better-auth directly
      const response = await auth.handler(request);

      // Convert Response back to Express response
      res.status(response.status);

      // Copy headers
      response.headers.forEach((value, key) => {
        res.setHeader(key, value);
      });

      // Send body
      const body = await response.text();
      res.send(body);
    } catch (error) {
      console.error("Auth route error:", error);
      res.status(500).json({
        error: "Internal server error",
        details: error instanceof Error ? error.message : String(error),
      });
    }
    return;
  }
  next();
});

// Mount public endpoints routes (must be before JSON middleware to handle raw streams)
app.use("/metamcp", publicEndpointsRouter);

// Mount MCP proxy routes
app.use("/mcp-proxy", mcpProxyRouter);

// Mount tRPC routes
app.use("/trpc", trpcRouter);

// Mount n8n webhook routes
app.use("/api/webhooks", n8nWebhooksRouter);

const PORT = process.env.PORT || 12009;

app.listen(PORT, async () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Auth routes available at: http://localhost:${PORT}/api/auth`);
  console.log(
    `Public MetaMCP endpoints available at: http://localhost:${PORT}/metamcp`,
  );
  console.log(
    `MCP Proxy routes available at: http://localhost:${PORT}/mcp-proxy`,
  );
  console.log(`tRPC routes available at: http://localhost:${PORT}/trpc`);
  console.log(`n8n Webhooks available at: http://localhost:${PORT}/api/webhooks`);

  // Wait a moment for the server to be fully ready to handle incoming connections,
  // then initialize idle servers (prevents connection errors when MCP servers connect back)
  console.log(
    "Waiting for server to be fully ready before initializing idle servers...",
  );
  await new Promise((resolve) => setTimeout(resolve, 3000)).then(
    initializeIdleServers,
  );
});

app.get("/health", (req, res) => {
  res.json({
    status: "ok",
  });
});
