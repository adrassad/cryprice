import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const rootDir = join(__dirname, "..");
const distDir = join(rootDir, "dist");
const ssrDir = join(rootDir, "dist-ssr");

const ROUTES = [
  { path: "/", outFile: "index.html" },
  { path: "/about", outFile: "about/index.html" },
  { path: "/security", outFile: "security/index.html" },
  { path: "/trust", outFile: "trust/index.html" },
  { path: "/transparency", outFile: "transparency/index.html" },
  { path: "/privacy", outFile: "privacy/index.html" },
  { path: "/terms", outFile: "terms/index.html" },
  { path: "/faq", outFile: "faq/index.html" },
  { path: "/contact", outFile: "contact/index.html" },
  { path: "/cookies", outFile: "cookies/index.html" },
  { path: "/docs", outFile: "docs/index.html" },
  { path: "/supported-protocols", outFile: "supported-protocols/index.html" },
  { path: "/changelog", outFile: "changelog/index.html" },
  { path: "/status", outFile: "status/index.html" },
];

const template = readFileSync(join(distDir, "index.html"), "utf-8");
const { renderRoute } = await import(join(ssrDir, "prerender.js"));

const HEAD_TAG_PATTERN =
  /^(?:<title[\s\S]*?<\/title>|<meta[\s\S]*?\/?>|<link[\s\S]*?\/?>)\s*/i;

/** React 19 renders Helmet tags inline; extract them for <head> injection. */
function splitHeadTags(appHtml) {
  let remaining = appHtml;
  const headTags = [];

  while (true) {
    const match = remaining.match(HEAD_TAG_PATTERN);
    if (!match) {
      break;
    }

    headTags.push(match[0].trim());
    remaining = remaining.slice(match[0].length);
  }

  return {
    headTags: headTags.join("\n    "),
    bodyHtml: remaining,
  };
}

function hasRouteMetadata(headTags) {
  return /<title[\s>]/i.test(headTags) || /property="og:title"/i.test(headTags);
}

function replaceDefaultHeadMetadata(html, headTags) {
  let next = html;
  next = next.replace(/<title[\s\S]*?<\/title>\s*/i, "");
  next = next.replace(/<meta\s+name="description"[\s\S]*?\/>\s*/gi, "");
  next = next.replace(/<meta\s+name="robots"[\s\S]*?\/>\s*/gi, "");
  next = next.replace(/<link\s+rel="canonical"[\s\S]*?\/>\s*/gi, "");
  next = next.replace(/<link\s+rel="alternate"[\s\S]*?\/>\s*/gi, "");
  next = next.replace(/<meta\s+property="og:[^"]+"[\s\S]*?\/>\s*/gi, "");
  next = next.replace(/<meta\s+name="twitter:[^"]+"[\s\S]*?\/>\s*/gi, "");

  return next.replace("</head>", `    ${headTags}\n  </head>`);
}

function injectAppHtml(html, appHtml) {
  const marker = '<div id="root">';
  const start = html.indexOf(marker);
  if (start === -1) {
    throw new Error('Could not find <div id="root"> in dist/index.html');
  }

  const end = html.indexOf("</div>", start);
  if (end === -1) {
    throw new Error(
      "Could not find closing </div> for #root in dist/index.html",
    );
  }

  return `${html.slice(0, start + marker.length)}${appHtml}${html.slice(end)}`;
}

for (const { path, outFile } of ROUTES) {
  const { appHtml } = renderRoute(path);
  const { headTags, bodyHtml } = splitHeadTags(appHtml);

  let html = injectAppHtml(template, bodyHtml);

  if (headTags && hasRouteMetadata(headTags)) {
    html = replaceDefaultHeadMetadata(html, headTags);
  }

  const outPath = join(distDir, outFile);
  mkdirSync(dirname(outPath), { recursive: true });
  writeFileSync(outPath, html, "utf-8");
  console.log(`prerendered ${path} -> dist/${outFile}`);
}
