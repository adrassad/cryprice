import express from "express";
import {
  ContactFormError,
  submitContactForm,
} from "../../services/contact/contactForm.service.js";

const router = express.Router();

router.post("/", async (req, res) => {
  try {
    await submitContactForm({
      body: req.body,
      remoteIp: req.ip,
    });
    res.status(200).json({ ok: true });
  } catch (error) {
    if (error instanceof ContactFormError) {
      res.status(error.status).json({
        error: {
          code: error.code,
          message: error.message,
        },
      });
      return;
    }

    console.error("[contact] submission failed", error);
    res.status(500).json({
      error: {
        code: "CONTACT_SEND_FAILED",
        message: "Unable to send your message. Please try again later.",
      },
    });
  }
});

export default router;
