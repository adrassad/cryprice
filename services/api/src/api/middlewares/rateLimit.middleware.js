import rateLimit from 'express-rate-limit';

// Ограничение: 60 запросов в минуту с одного IP
const apiLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 минута
  max: 60,                 // максимум 60 запросов
  standardHeaders: true,   // отправлять X-RateLimit-* заголовки
  legacyHeaders: false,    // отключить X-RateLimit-* заголовки старого формата
  message: {
    error: 'Too many requests, please try again later.'
  }
});

export default apiLimiter;
