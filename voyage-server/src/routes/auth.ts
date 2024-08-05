// src/routes/auth.ts
import express from 'express';
import { User } from '../models/User';

const router = express.Router();

router.get('/login', (req: express.Request, res: express.Response) => {
    // Assume you have a login form
    // Check user credentials and set session if valid
    const user: User = { id: 'user123', username: 'example', password: 'password' };
    req.session.user = user;
    res.send('Logged in successfully');
});

router.get('/dashboard', (req: express.Request, res: express.Response) => {
    if (req.session.user != undefined) {
        const user: User = req.session.user;
        res.send(`Welcome to the Dashboard, ${user.username}!`);
    } else {
        res.send('User not logged in')
    }
});

router.get('/logout', (req: express.Request, res: express.Response) => {
    // Destroy session on logout
    req.session.destroy((err) => {
        if (err) {
            return res.status(500).send('Internal Server Error');
        }
        res.send('Logged out successfully');
    });
});

export default router;
