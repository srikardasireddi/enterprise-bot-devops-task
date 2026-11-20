const http = require("http");
const os = require("os");

const port = Number(process.env.PORT) || 8080;
const appName = process.env.APP_NAME || "demo-service";
const version = process.env.VERSION || "0.1.0";
const podName = os.hostname();

const server = http.createServer((req, res) => {
  const urlPath = (req.url || "/").split("?")[0];

  if (req.method === "GET" && urlPath === "/") {
    const payload = JSON.stringify({
      app: appName,
      version: version,
      pod: podName,
    });
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(payload);
    return;
  }

  if (req.method === "GET" && urlPath === "/healthz") {
    res.writeHead(200, { "Content-Type": "text/plain" });
    res.end("ok");
    return;
  }

  res.writeHead(404, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ error: "not found" }));
});

server.listen(port, "0.0.0.0", () => {
  console.log(`Listening on port ${port} (app=${appName}, version=${version})`);
});
