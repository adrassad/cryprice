/**
 * Isolated HTTP checks for GET / API identity (exits process).
 */
import http from "node:http";
import { strictEqual, ok } from "node:assert";
import "dotenv/config";
import { createApp } from "../../../src/api/server.js";
import { API_IDENTITY_PAYLOAD } from "../../../src/api/routes/apiIdentity.route.js";

function requestApp(app, { method = "GET", path = "/" } = {}) {
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

  const root = await requestApp(app, { method: "GET", path: "/" });
  strictEqual(root.status, 200, "GET / must return 200");
  ok(root.contentType?.includes("application/json"), "GET / must return JSON");

  strictEqual(root.json?.name, "CryPrice API");
  strictEqual(root.json?.status, "ok");
  strictEqual(root.json?.readOnly, true);
  strictEqual(root.json?.security?.publicAddressesOnly, true);
  strictEqual(root.json?.authentication?.provider, "Google OAuth");
  strictEqual(root.json?.links?.website, "https://cryprice.dev");
  strictEqual(root.json?.links?.contact, API_IDENTITY_PAYLOAD.links.contact);

  const health = await requestApp(app, { method: "GET", path: "/health" });
  strictEqual(health.status, 200);
}

try {
  await runChecks();
  console.log(JSON.stringify({ ok: true }));
  process.exit(0);
} catch (err) {
  console.error(err?.message ?? err);
  process.exit(1);
}
