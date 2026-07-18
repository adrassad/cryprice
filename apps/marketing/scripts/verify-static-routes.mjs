import { existsSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { dirname } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const rootDir = join(__dirname, "..");
const publicDir = join(rootDir, "public");
const distDir = join(rootDir, "dist");

const PRERENDERED_ROUTES = [
  "index.html",
  "about/index.html",
  "security/index.html",
  "trust/index.html",
  "transparency/index.html",
  "privacy/index.html",
  "terms/index.html",
  "faq/index.html",
  "contact/index.html",
  "cookies/index.html",
  "docs/index.html",
  "supported-protocols/index.html",
  "changelog/index.html",
  "status/index.html",
];

const FAKE_ROUTE_DIRS = [
  "login",
  "connect-wallet",
  "verify-wallet",
  "wallet",
  "seed",
];

function assert(condition, message) {
  if (!condition) {
    console.error(message);
    process.exitCode = 1;
  }
}

assert(existsSync(join(publicDir, "404.html")), "public/404.html must exist");

const notFoundHtml = await import("node:fs").then((fs) =>
  fs.readFileSync(join(publicDir, "404.html"), "utf8"),
);
assert(
  notFoundHtml.includes("noindex"),
  "public/404.html must include noindex robots meta",
);
assert(notFoundHtml.includes('href="/"'), "public/404.html must link to home");
assert(
  notFoundHtml.includes("Official Domains"),
  "public/404.html must list official domains",
);
assert(
  notFoundHtml.includes("application/ld+json"),
  "public/404.html must include JSON-LD",
);
assert(
  notFoundHtml.includes("/security/"),
  "public/404.html must link to security",
);
assert(
  notFoundHtml.includes("Security notice"),
  "public/404.html must include security notice",
);
assert(
  notFoundHtml.includes("Need help?"),
  "public/404.html must include Need help section",
);
assert(
  notFoundHtml.includes('aria-label="Breadcrumb"'),
  "public/404.html must include breadcrumb nav",
);
assert(
  notFoundHtml.includes("BreadcrumbList"),
  "public/404.html must include BreadcrumbList JSON-LD",
);
assert(
  notFoundHtml.includes("Last updated: 2026"),
  "public/404.html must include last updated",
);
assert(
  notFoundHtml.includes("/docs/"),
  "public/404.html must link to documentation",
);

if (existsSync(distDir)) {
  assert(
    existsSync(join(distDir, "404.html")),
    "dist/404.html must exist after build",
  );

  for (const routeFile of PRERENDERED_ROUTES) {
    assert(
      existsSync(join(distDir, routeFile)),
      `dist/${routeFile} must exist after prerender`,
    );
  }

  for (const fakeDir of FAKE_ROUTE_DIRS) {
    assert(
      !existsSync(join(distDir, fakeDir)),
      `dist/${fakeDir}/ must not exist (would imply a fake route was built)`,
    );
  }

} else {
  console.log(
    "dist/ not found — skipping post-build route checks (run npm run build first)",
  );
}

if (process.exitCode) {
  process.exit(process.exitCode);
}

console.log("OK: static route checks passed");
