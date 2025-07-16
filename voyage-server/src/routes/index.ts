// src/routes/index.ts
import express from 'express';
import { User } from '../models/user.model';
import userRouter from './user.route';
import tripRouter from './trip.route';
import tripDayRouter from './trip-day.route';
import activityRouter from './activity.route';

// src/routes/index.ts
const router = express.Router();

// Dashboard route
router.get('/dashboard', (req: express.Request, res: express.Response) => {
    if (req.session.user != undefined) {
        const user = req.session.user as User;
        res.send(`Welcome to the Dashboard, ${user.username}!`);
    } else {
        res.send('User not logged in');
    }
});

router.get('/', (req, res) => res.send('VoyagePilot server v1.0.0'));
router.use('/users', userRouter);
router.use('/trips', tripRouter);
router.use('/trip-days', tripDayRouter);
router.use('/activities', activityRouter);

export default router;
