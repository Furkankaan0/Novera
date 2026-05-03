// src/routes/teams.ts
// Növera API — Team Routes

import { Router, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { authenticate, AuthRequest } from '../middleware/auth';

export const teamsRouter = Router();
const teams: Map<string, any> = new Map();

teamsRouter.get('/', authenticate, (req: AuthRequest, res: Response): void => {
  const userTeams = [...teams.values()].filter(t =>
    t.members.some((m: any) => m.userId === req.userId)
  );
  res.json(userTeams);
});

teamsRouter.post('/', authenticate, (req: AuthRequest, res: Response): void => {
  const team = {
    id: uuidv4(),
    createdBy: req.userId,
    inviteCode: Math.random().toString(36).substring(2, 8).toUpperCase(),
    members: [{ userId: req.userId, role: 'admin', joinedAt: new Date().toISOString() }],
    ...req.body,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
  teams.set(team.id, team);
  res.status(201).json(team);
});

teamsRouter.post('/join', authenticate, (req: AuthRequest, res: Response): void => {
  const { inviteCode } = req.body;
  const team = [...teams.values()].find(t => t.inviteCode === inviteCode?.toUpperCase());
  if (!team) {
    res.status(404).json({ error: 'Geçersiz davet kodu.' });
    return;
  }
  team.members.push({ userId: req.userId, role: 'member', joinedAt: new Date().toISOString() });
  teams.set(team.id, team);
  res.json(team);
});
