// src/routes/shifts.ts
// Növera API — Shifts CRUD Routes

import { Router, Response } from 'express';
import { body, validationResult } from 'express-validator';
import { v4 as uuidv4 } from 'uuid';
import { authenticate, AuthRequest } from '../middleware/auth';

export const shiftsRouter = Router();

// In-memory store (replace with PostgreSQL/Supabase)
const shifts: Map<string, any> = new Map();

// GET /shifts — Get user's shifts
shiftsRouter.get('/', authenticate, (req: AuthRequest, res: Response): void => {
  const { since, month } = req.query;
  let result = [...shifts.values()].filter(s =>
    s.userId === req.userId && !s.deletedAt
  );
  if (since) {
    result = result.filter(s => new Date(s.updatedAt) > new Date(since as string));
  }
  if (month) {
    const d = new Date(month as string);
    result = result.filter(s => {
      const sd = new Date(s.startDate);
      return sd.getFullYear() === d.getFullYear() && sd.getMonth() === d.getMonth();
    });
  }
  res.json(result.sort((a, b) => new Date(a.startDate).getTime() - new Date(b.startDate).getTime()));
});

// POST /shifts — Create shift
shiftsRouter.post('/',
  authenticate,
  [
    body('title').notEmpty(),
    body('startDate').isISO8601(),
    body('endDate').isISO8601(),
    body('shiftType').isIn(['day', 'night', 'oncall', 'holiday', 'overtime']),
  ],
  (req: AuthRequest, res: Response): void => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      res.status(400).json({ errors: errors.array() });
      return;
    }
    const shift = {
      id: uuidv4(),
      userId: req.userId,
      ...req.body,
      syncStatus: 'synced',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      deletedAt: null,
    };
    shifts.set(shift.id, shift);
    res.status(201).json(shift);
  }
);

// PUT /shifts/:id — Update shift
shiftsRouter.put('/:id', authenticate, (req: AuthRequest, res: Response): void => {
  const shift = shifts.get(req.params.id);
  if (!shift || shift.userId !== req.userId) {
    res.status(404).json({ error: 'Vardiya bulunamadı.' });
    return;
  }
  const updated = { ...shift, ...req.body, updatedAt: new Date().toISOString() };
  shifts.set(shift.id, updated);
  res.json(updated);
});

// DELETE /shifts/:id — Soft delete
shiftsRouter.delete('/:id', authenticate, (req: AuthRequest, res: Response): void => {
  const shift = shifts.get(req.params.id);
  if (!shift || shift.userId !== req.userId) {
    res.status(404).json({ error: 'Vardiya bulunamadı.' });
    return;
  }
  shifts.set(shift.id, {
    ...shift,
    deletedAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  });
  res.status(204).send();
});


