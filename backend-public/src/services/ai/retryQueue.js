// src/services/ai/retryQueue.js

export function scheduleRetry({ delayMs, task }) {
  setTimeout(async () => {
    try {
      await task();
    } catch (err) {
      console.error("Retry failed:", err);
    }
  }, delayMs);
}
