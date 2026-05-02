// src/index.js
import "./config/env.js";
import { startApplication } from "./app/index.js";

startApplication().catch((e) => {
  console.error("❌ Fatal error", new Date().toISOString(), e);
  process.exit(1);
});
