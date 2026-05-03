// src/index.ts
// Növera API — Express Application Entry Point

import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { authRouter } from './routes/auth';
import { usersRouter } from './routes/users';
import { shiftsRouter } from './routes/shifts';
import { teamsRouter } from './routes/teams';
import { announcementsRouter } from './routes/announcements';
import { swapRequestsRouter } from './routes/swapRequests';
import { errorHandler } from './middleware/errorHandler';
import { requestLogger } from './middleware/requestLogger';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  credentials: true,
}));
app.use(express.json());
app.use(requestLogger);

// Health check
app.get('/health', (_, res) => {
  res.json({ status: 'ok', version: '1.0.0', timestamp: new Date().toISOString() });
});

// Routes
app.use('/api/v1/auth', authRouter);
app.use('/api/v1/users', usersRouter);
app.use('/api/v1/shifts', shiftsRouter);
app.use('/api/v1/teams', teamsRouter);
app.use('/api/v1/announcements', announcementsRouter);
app.use('/api/v1/swap-requests', swapRequestsRouter);

// Error handler
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`🏥 Növera API running on port ${PORT}`);
});

export default app;
