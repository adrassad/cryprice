/**
 * Isolated HTTP checks for GET /.well-known/security.txt (exits process).
 */
import http from "node:http";
import { strictEqual, ok } from "node:assert";
import "dotenv/config";
import { createApp } from "../../../src/api/server.js";
import { API_SECURITY_TXT } from "../../../src/api/routes/securityTxt.route.js";
import { API_IDENTITY_PAYLOAD } from "../../../src/api/routes/apiIdentity.route.js";

function requestApp(app, { method = "GET", path = "/.well-known/security.txt" } = {}) {
  return new Promise((resolve, reject) => {
    const server = http.createServer(app);
    server.listen(0, "127.0.0.1", () => {
      const { port } = server.address();
      fetch(`http://127.0.0.1:${port}${path}`, { method })
        .then(async (res) => {
          const text = await res.text();
          let json = null;
          try {
            json = text ? JSON.parse(text) : null;
          } catch {
            json = null;
          }
          server.close();
          resolve({
            status: res.status,
            json,
            text,
            contentType: res.headers.get("content-type"),
          });
        })
        .catch((err) => {
          server.close();
          reject(err);
        });
    });
    server.on("error", reject);
  });
}

async function runChecks() {
  const app = createApp();

  const security = await requestApp(app, {
    method: "GET",
    path: "/.well-known/security.txt",
  });
  strictEqual(security.status, 200, "GET /.well-known/security.txt must return 200");
  ok(
    security.contentType?.includes("text/plain"),
    "security.txt must return text/plain",
  );
  strictEqual(security.text, API_SECURITY_TXT);
  ok(security.text.includes("Contact: mailto:security@cryprice.dev"));

  const root = await requestApp(app, { method: "GET", path: "/" });
  strictEqual(root.status, 200);
  ok(root.contentType?.includes("application/json"));
  strictEqual(root.json?.name, API_IDENTITY_PAYLOAD.name);
}

try {
  await runChecks();
  console.log(JSON.stringify({ ok: true }));
  process.exit(0);
} catch (err) {
  console.error(err?.message ?? err);
  process.exit(1);
}
