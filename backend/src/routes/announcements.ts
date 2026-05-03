// src/routes/announcements.ts
// Növera API — Announcement Routes

import { Router, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { authenticate, AuthRequest } from '../middleware/auth';

export const announcementsRouter = Router();
const announcements: Map<string, any> = new Map();

announcementsRouter.get('/', authenticate, (req: AuthRequest, res: Response): void => {
  const { teamId } = req.query;
  const result = [...announcements.values()].filter(a => a.teamId === teamId);
  res.json(result);
});

announcementsRouter.post('/', authenticate, (req: AuthRequest, res: Response): void => {
  const ann = {
    id: uuidv4(),
    createdBy: req.userId,
    ...req.body,
    createdAt: new Date().toISOString(),
  };
  announcements.set(ann.id, ann);
  res.status(201).json(ann);
});
