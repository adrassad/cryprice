import { spawn } from "node:child_process";
import { ENV } from "../../config/env.js";

/**
 * @param {{ to: string, from: string, replyTo: string, subject: string, text: string }} mail
 */
export async function sendContactFormEmail(mail) {
  if (ENV.CONTACT_FORM_DRY_RUN) {
    console.info("[contact] dry-run email", {
      to: mail.to,
      subject: mail.subject,
    });
    return;
  }

  const message = [
    `From: CryPrice Contact <${mail.from}>`,
    `To: ${mail.to}`,
    `Reply-To: ${mail.replyTo}`,
    `Subject: ${mail.subject}`,
    "MIME-Version: 1.0",
    "Content-Type: text/plain; charset=utf-8",
    "",
    mail.text,
  ].join("\n");

  const sendmailPath = ENV.CONTACT_SENDMAIL_PATH || "/usr/sbin/sendmail";

  await new Promise((resolve, reject) => {
    const proc = spawn(sendmailPath, ["-t", "-i", "-f", mail.from], {
      stdio: ["pipe", "ignore", "pipe"],
    });

    let stderr = "";
    proc.stderr.on("data", (chunk) => {
      stderr += chunk;
    });
    proc.stdin.write(message);
    proc.stdin.end();
    proc.on("error", reject);
    proc.on("close", (code) => {
      if (code === 0) {
        resolve();
        return;
      }
      reject(new Error(stderr.trim() || `sendmail exited with code ${code}`));
    });
  });
}
