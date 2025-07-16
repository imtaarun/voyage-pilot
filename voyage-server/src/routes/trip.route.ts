import express from 'express';
import * as tripService from '../service/trip.service';

const router = express.Router();

router.get('/', tripService.getAllTrips);
router.get('/:id', tripService.getTripById);
router.post('/', tripService.createTrip);
router.put('/:id', tripService.updateTrip);
router.delete('/:id', tripService.deleteTrip);
router.post('/generate', tripService.autoGenerateTrip);

export default router;