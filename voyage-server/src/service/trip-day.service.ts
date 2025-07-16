import { Request, Response } from 'express';
import { TripDay } from '../models/trip-day.model';

// Helper function for basic validation
function validateTripDayInput(body: any) {
  const errors: string[] = [];
  if (!body.tripId || typeof body.tripId !== 'number') errors.push('tripId is required and must be a number.');
  if (!body.date || isNaN(Date.parse(body.date))) errors.push('Valid date is required.');
  if (body.name && typeof body.name !== 'string') errors.push('Name must be a string if provided.');
  return errors;
}

export const getAllTripDays = async (_: Request, res: Response) => {
  try {
    const tripDays = await TripDay.findAll();
    res.json(tripDays);
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(200).json([]);
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const getTripDayById = async (req: Request, res: Response) => {
  try {
    const tripDay = await TripDay.findByPk(req.params.id);
    if (tripDay) return res.json(tripDay);
    return res.status(404).json({ message: 'TripDay not found' });
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(200).json(null);
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const createTripDay = async (req: Request, res: Response) => {
  try {
    const errors = validateTripDayInput(req.body);
    if (errors.length > 0) {
      return res.status(400).json({ errors });
    }
    const tripDay = await TripDay.create(req.body);
    res.status(201).json(tripDay);
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(200).json(null);
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const updateTripDay = async (req: Request, res: Response) => {
  try {
    const tripDay = await TripDay.findByPk(req.params.id);
    if (!tripDay) {
      return res.status(404).json({ message: 'TripDay not found' });
    }
    if ('tripId' in req.body && typeof req.body.tripId !== 'number') {
      return res.status(400).json({ message: 'tripId must be a number.' });
    }
    if ('date' in req.body && isNaN(Date.parse(req.body.date))) {
      return res.status(400).json({ message: 'date must be a valid date.' });
    }
    if ('name' in req.body && typeof req.body.name !== 'string') {
      return res.status(400).json({ message: 'name must be a string.' });
    }
    await tripDay.update(req.body);
    return res.json(tripDay);
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(200).json(null);
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const deleteTripDay = async (req: Request, res: Response) => {
  try {
    const tripDay = await TripDay.findByPk(req.params.id);
    if (tripDay) {
      await tripDay.destroy();
      return res.status(204).send();
    }
    return res.status(404).json({ message: 'TripDay not found' });
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(204).send();
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};
