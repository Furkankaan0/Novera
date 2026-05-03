// src/routes/auth.ts
// Növera API — Authentication Routes

import { Router, Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { body, validationResult } from 'express-validator';
import { v4 as uuidv4 } from 'uuid';

export const authRouter = Router();

const JWT_SECRET = process.env.JWT_SECRET || 'novera-dev-secret';
const JWT_EXPIRES_IN = '7d';
const REFRESH_EXPIRES_IN = '30d';

// In-memory user store for MVP (replace with PostgreSQL)
const users: Map<string, any> = new Map();

// POST /auth/register
authRouter.post('/register',
  [
    body('name').notEmpty().withMessage('Ad gerekli'),
    body('email').isEmail().withMessage('Geçerli email gerekli'),
    body('password').isLength({ min: 6 }).withMessage('Şifre en az 6 karakter olmalı'),
  ],
  async (req: Request, res: Response): Promise<void> => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      res.status(400).json({ errors: errors.array() });
      return;
    }

    const { name, email, password, profession, department } = req.body;

    if ([...users.values()].some(u => u.email === email)) {
      res.status(409).json({ error: 'Bu email zaten kayıtlı.' });
      return;
    }

    const hashedPassword = await bcrypt.hash(password, 12);
    const userId = uuidv4();
    const user = {
      id: userId,
      name,
      email,
      password: hashedPassword,
      role: 'member',
      profession: profession || 'other',
      department: department || '',
      createdAt: new Date().toISOString(),
    };
    users.set(userId, user);

    const token = generateToken(userId, user.role);
    const refreshToken = generateRefreshToken(userId);

    res.status(201).json({
      user: sanitizeUser(user),
      token,
      refreshToken,
    });
  }
);

// POST /auth/login
authRouter.post('/login',
  [
    body('email').isEmail(),
    body('password').notEmpty(),
  ],
  async (req: Request, res: Response): Promise<void> => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      res.status(400).json({ errors: errors.array() });
      return;
    }

    const { email, password } = req.body;
    const user = [...users.values()].find(u => u.email === email);

    if (!user || !(await bcrypt.compare(password, user.password))) {
      res.status(401).json({ error: 'Email veya şifre hatalı.' });
      return;
    }

    const token = generateToken(user.id, user.role);
    const refreshToken = generateRefreshToken(user.id);

    res.json({
      user: sanitizeUser(user),
      token,
      refreshToken,
    });
  }
);

// POST /auth/apple
authRouter.post('/apple', async (req: Request, res: Response): Promise<void> => {
  // TODO: Verify Apple identity token with Apple's public key
  const { identityToken, name, email } = req.body;
  if (!identityToken) {
    res.status(400).json({ error: 'Identity token gerekli.' });
    return;
  }
  // Stub: create/find user
  const userId = uuidv4();
  const user = {
    id: userId,
    name: name || 'Apple Kullanıcısı',
    email: email || `${userId}@privaterelay.appleid.com`,
    role: 'member',
    profession: 'other',
    department: '',
    createdAt: new Date().toISOString(),
  };
  users.set(userId, user);
  res.json({
    user: sanitizeUser(user),
    token: generateToken(userId, user.role),
    refreshToken: generateRefreshToken(userId),
  });
});

// POST /auth/refresh
authRouter.post('/refresh', (req: Request, res: Response): void => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    res.status(400).json({ error: 'Refresh token gerekli.' });
    return;
  }
  try {
    const decoded = jwt.verify(refreshToken, JWT_SECRET) as { userId: string; role: string };
    const token = generateToken(decoded.userId, decoded.role);
    res.json({ token });
  } catch {
    res.status(401).json({ error: 'Geçersiz refresh token.' });
  }
});

// Helpers
function generateToken(userId: string, role: string): string {
  return jwt.sign({ userId, role }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
}

function generateRefreshToken(userId: string): string {
  return jwt.sign({ userId }, JWT_SECRET, { expiresIn: REFRESH_EXPIRES_IN });
}

function sanitizeUser(user: any) {
  const { password, ...safe } = user;
  return safe;
}
