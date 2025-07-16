import express from 'express';
import * as tripDayService from '../service/trip-day.service';

const router = express.Router();

router.get('/', tripDayService.getAllTripDays);
router.get('/:id', tripDayService.getTripDayById);
router.post('/', tripDayService.createTripDay);
router.put('/:id', tripDayService.updateTripDay);
router.delete('/:id', tripDayService.deleteTripDay);

export default router;