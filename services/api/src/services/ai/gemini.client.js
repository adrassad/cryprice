import { GoogleGenAI } from "@google/genai";
import { ENV } from "../../config/env.js";

let aiInstance = null;

export function getGeminiClient() {
  if (!aiInstance) {
    aiInstance = new GoogleGenAI({
      apiKey: ENV.GEMINI_API_KEY,
    });
  }

  return aiInstance;
}
