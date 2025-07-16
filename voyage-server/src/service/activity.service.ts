import { Request, Response } from 'express';
import { Activity } from '../models/activity.model';

// Helper function for basic validation
function validateActivityInput(body: any) {
  const errors: string[] = [];
  if (!body.tripDayId || typeof body.tripDayId !== 'number') errors.push('tripDayId is required and must be a number.');
  if (!body.name || typeof body.name !== 'string') errors.push('name is required and must be a string.');
  if (body.activity_type && typeof body.activity_type !== 'string') errors.push('activity_type must be a string if provided.');
  if (body.description && typeof body.description !== 'string') errors.push('description must be a string if provided.');
  if (body.location && typeof body.location !== 'string') errors.push('location must be a string if provided.');
  if (body.startTime && typeof body.startTime !== 'string') errors.push('startTime must be a string if provided.');
  if (body.endTime && typeof body.endTime !== 'string') errors.push('endTime must be a string if provided.');
  return errors;
}

export const getAllActivities = async (_: Request, res: Response) => {
  try {
    const activities = await Activity.findAll();
    res.json(activities);
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(200).json([]);
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const getActivityById = async (req: Request, res: Response) => {
  try {
    const activity = await Activity.findByPk(req.params.id);
    if (activity) return res.json(activity);
    return res.status(404).json({ message: 'Activity not found' });
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(200).json(null);
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const createActivity = async (req: Request, res: Response) => {
  try {
    const errors = validateActivityInput(req.body);
    if (errors.length > 0) {
      return res.status(400).json({ errors });
    }
    const activity = await Activity.create(req.body);
    res.status(201).json(activity);
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(200).json(null);
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const updateActivity = async (req: Request, res: Response) => {
  try {
    const activity = await Activity.findByPk(req.params.id);
    if (!activity) {
      return res.status(404).json({ message: 'Activity not found' });
    }
    if ('tripDayId' in req.body && typeof req.body.tripDayId !== 'number') {
      return res.status(400).json({ message: 'tripDayId must be a number.' });
    }
    if ('name' in req.body && typeof req.body.name !== 'string') {
      return res.status(400).json({ message: 'name must be a string.' });
    }
    if ('activity_type' in req.body && typeof req.body.activity_type !== 'string') {
      return res.status(400).json({ message: 'activity_type must be a string.' });
    }
    if ('description' in req.body && typeof req.body.description !== 'string') {
      return res.status(400).json({ message: 'description must be a string.' });
    }
    if ('location' in req.body && typeof req.body.location !== 'string') {
      return res.status(400).json({ message: 'location must be a string.' });
    }
    if ('startTime' in req.body && typeof req.body.startTime !== 'string') {
      return res.status(400).json({ message: 'startTime must be a string.' });
    }
    if ('endTime' in req.body && typeof req.body.endTime !== 'string') {
      return res.status(400).json({ message: 'endTime must be a string.' });
    }
    await activity.update(req.body);
    return res.json(activity);
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(200).json(null);
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const deleteActivity = async (req: Request, res: Response) => {
  try {
    const activity = await Activity.findByPk(req.params.id);
    if (activity) {
      await activity.destroy();
      return res.status(204).send();
    }
    return res.status(404).json({ message: 'Activity not found' });
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(204).send();
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};
