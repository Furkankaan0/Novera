// src/routes/users.ts
// Növera API — User Routes

import { Router, Response } from 'express';
import { authenticate, AuthRequest } from '../middleware/auth';

export const usersRouter = Router();

usersRouter.get('/me', authenticate, (req: AuthRequest, res: Response): void => {
  // TODO: Fetch from DB
  res.json({ userId: req.userId });
});
