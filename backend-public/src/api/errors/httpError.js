export class HttpError extends Error {
  /**
   * @param {number} status HTTP status
   * @param {string} code Machine-readable code
   * @param {string} message Safe client message
   */
  constructor(status, code, message) {
    super(message);
    this.name = "HttpError";
    this.status = status;
    this.code = code;
  }
}
