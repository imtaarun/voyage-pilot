// src/routes/auth.ts
import express from 'express';
import { User } from '../models/user.model';
import bcrypt from 'bcrypt';

const router = express.Router();

router.post('/login', async (req: express.Request, res: express.Response) => {
    // Mock user for demonstration using Sequelize's build method
    const user = await User.findOne({ where: { email: req.body.email } });
      if (!user) {
        return res.status(401).json({ message: 'user with email ' + req.body.email + ' not found' });
      }
      const isValid = await bcrypt.compareSync(req.body.password, user.passwordHash);
      if (!isValid) {
        return res.status(401).json({ message: 'Invalid email and password combination' });
      }
    req.session.user = user;
    return res.status(200).json({ message: 'Login successful', user: { id: user.id, username: user.username, email: user.email } });
});

router.get('/logout', (req: express.Request, res: express.Response) => {
    req.session.destroy((err) => {
        if (err) {
            return res.status(500).send('Internal Server Error');
        }
        res.send('Logged out successfully');
    });
});

export default router;