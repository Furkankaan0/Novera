// src/routes/swapRequests.ts
// Növera API — Shift Swap Request Routes

import { Router, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { authenticate, AuthRequest } from '../middleware/auth';

export const swapRequestsRouter = Router();
const swapRequests: Map<string, any> = new Map();

swapRequestsRouter.get('/', authenticate, (req: AuthRequest, res: Response): void => {
  const result = [...swapRequests.values()].filter(
    r => r.requestedBy === req.userId || r.requestedTo === req.userId
  );
  res.json(result);
});

swapRequestsRouter.post('/', authenticate, (req: AuthRequest, res: Response): void => {
  const request = {
    id: uuidv4(),
    requestedBy: req.userId,
    status: 'pending',
    ...req.body,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
  swapRequests.set(request.id, request);
  res.status(201).json(request);
});

swapRequestsRouter.patch('/:id/respond', authenticate, (req: AuthRequest, res: Response): void => {
  const request = swapRequests.get(req.params.id);
  if (!request) {
    res.status(404).json({ error: 'Takas isteği bulunamadı.' });
    return;
  }
  const { status } = req.body;
  if (!['accepted', 'rejected'].includes(status)) {
    res.status(400).json({ error: 'Geçersiz durum.' });
    return;
  }
  const updated = { ...request, status, updatedAt: new Date().toISOString() };
  swapRequests.set(request.id, updated);
  res.json(updated);
});
