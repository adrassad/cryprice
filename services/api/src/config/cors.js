import cors from "cors";
import { ENV } from "./env.js";
import {
  isLocalDevOrigin,
  resolveCorsOriginPolicy,
} from "./cors.policy.js";

export {
  parseCorsAllowedOrigins,
  resolveCorsOriginPolicy,
  isLocalDevOrigin,
} from "./cors.policy.js";

export function createCorsMiddleware() {
  const configured = ENV.CORS_ALLOWED_ORIGINS;
  const explicitOrigins = resolveCorsOriginPolicy(ENV.NODE_ENV, configured);

  if (explicitOrigins === null) {
    return cors({
      origin(origin, callback) {
        if (isLocalDevOrigin(origin)) {
          callback(null, true);
          return;
        }
        callback(new Error("Not allowed by CORS"));
      },
      credentials: true,
    });
  }

  return cors({
    origin: explicitOrigins,
    credentials: true,
  });
}
