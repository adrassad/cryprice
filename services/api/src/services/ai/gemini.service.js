// src/services/ai/gemini.service.js
import { getGeminiClient } from "./gemini.client.js";
import { ENV } from "../../config/env.js";

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function parseRetrySeconds(error) {
  const message = String(error?.message || "");
  const retryMatch = message.match(/"retryDelay":"(\d+)s"/);
  return retryMatch ? Number(retryMatch[1]) : null;
}

function is429(error) {
  return (
    error?.status === 429 ||
    String(error?.message || "").includes('"status":"RESOURCE_EXHAUSTED"')
  );
}

function is503(error) {
  return (
    error?.status === 503 ||
    String(error?.message || "").includes('"status":"UNAVAILABLE"')
  );
}

async function generateWithModel(ai, model, contents, config) {
  const response = await ai.models.generateContent({
    model,
    contents,
    config,
  });

  return response.text?.trim() || "";
}

export class GeminiService {
  async generateReply({ userText, profile, history = [], locale = "ru" }) {
    const ai = getGeminiClient();

    const contents = [
      {
        role: "user",
        parts: [{ text: userText }],
      },
    ];

    const config = {
      temperature: 0.4,
      maxOutputTokens: 500,
    };

    const primaryModel = ENV.GEMINI_MODEL || "gemini-2.5-flash";

    try {
      return await generateWithModel(ai, primaryModel, contents, config);
    } catch (error) {
      if (is429(error)) {
        const retrySeconds = parseRetrySeconds(error);
        const e = new Error("AI_QUOTA_EXHAUSTED");
        e.retrySeconds = retrySeconds;
        e.originalStatus = 429;
        throw e;
      }

      if (!is503(error)) {
        throw error;
      }
    }

    // retry only for 503
    for (const delay of [1000, 2500, 5000]) {
      await sleep(delay);

      try {
        return await generateWithModel(ai, primaryModel, contents, config);
      } catch (error) {
        if (is429(error)) {
          const retrySeconds = parseRetrySeconds(error);
          const e = new Error("AI_QUOTA_EXHAUSTED");
          e.retrySeconds = retrySeconds;
          e.originalStatus = 429;
          throw e;
        }

        if (!is503(error)) {
          throw error;
        }
      }
    }

    throw new Error("AI_TEMPORARILY_UNAVAILABLE");
  }
}
