// src/middleware/errorHandler.ts
// Növera API — Global Error Handler

import { Request, Response, NextFunction } from 'express';

export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
): void {
  console.error(`[ERROR] ${err.message}`, err.stack);
  res.status(500).json({
    error: 'Sunucu hatası oluştu.',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
}
