// src/routes/index.ts
import express from 'express';

const router = express.Router();

router.get('/', (req: express.Request, res: express.Response) => {
    res.send('VoyagePilot server v1.0.0');
});

export default router;
