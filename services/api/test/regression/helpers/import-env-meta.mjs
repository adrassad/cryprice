// Subprocess helper: import env with env vars supplied by parent (fresh module graph).
import { ENV, shouldFlushRedisOnStart } from "../../../src/config/env.js";

console.log(
  JSON.stringify({
    port: ENV.PORT_API,
    flush: shouldFlushRedisOnStart(),
  }),
);
