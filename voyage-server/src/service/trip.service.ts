import { Request, Response } from 'express';
import { Trip } from '../models/trip.model';
import { fetchGeminiData } from './gemini.api';

// Helper function for basic validation
function validateTripInput(body: any) {
  const errors: string[] = [];
  if (!body.name || typeof body.name !== 'string') errors.push('Name is required and must be a string.');
  if (!body.start_date || isNaN(Date.parse(body.start_date))) errors.push('Valid start_date is required.');
  if (!body.end_date || isNaN(Date.parse(body.end_date))) errors.push('Valid end_date is required.');
  if (
    body.start_date &&
    body.end_date &&
    !isNaN(Date.parse(body.start_date)) &&
    !isNaN(Date.parse(body.end_date)) &&
    new Date(body.end_date) < new Date(body.start_date)
  ) {
    errors.push('end_date must be after start_date.');
  }
  return errors;
}

export const getAllTrips = async (_: Request, res: Response) => {
  try {
    const trips = await Trip.findAll();
    res.json(trips);
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(200).json([]);
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const getTripById = async (req: Request, res: Response) => {
  try {
    const trip = await Trip.findByPk(req.params.id);
    if (trip) return res.json(trip);
    return res.status(404).json({ message: 'Trip not found' });
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(200).json(null);
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const createTrip = async (req: Request, res: Response) => {
  try {
    const errors = validateTripInput(req.body);
    if (errors.length > 0) {
      return res.status(400).json({ errors });
    }
    const trip = await Trip.create(req.body);
    res.status(201).json(trip);
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(200).json(null);
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const updateTrip = async (req: Request, res: Response) => {
  try {
    const trip = await Trip.findByPk(req.params.id);
    if (!trip) {
      return res.status(404).json({ message: 'Trip not found' });
    }
    const updateFields = ['name', 'start_date', 'end_date'];
    for (const field of updateFields) {
      if (field in req.body) {
        if (field === 'name' && typeof req.body[field] !== 'string') {
          return res.status(400).json({ message: 'Name must be a string.' });
        }
        if ((field === 'start_date' || field === 'end_date') && isNaN(Date.parse(req.body[field]))) {
          return res.status(400).json({ message: `${field} must be a valid date.` });
        }
      }
    }
    if (
      req.body.start_date &&
      req.body.end_date &&
      !isNaN(Date.parse(req.body.start_date)) &&
      !isNaN(Date.parse(req.body.end_date)) &&
      new Date(req.body.end_date) < new Date(req.body.start_date)
    ) {
      return res.status(400).json({ message: 'end_date must be after start_date.' });
    }
    await trip.update(req.body);
    return res.json(trip);
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(200).json(null);
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const deleteTrip = async (req: Request, res: Response) => {
  try {
    const trip = await Trip.findByPk(req.params.id);
    if (trip) {
      await trip.destroy();
      return res.status(204).send();
    }
    return res.status(404).json({ message: 'Trip not found' });
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(204).send();
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const autoGenerateTrip = async (req: Request, res: Response) => {
  try {
    const _prompt = `
    You are a travel planner assistant. Based on the following inputs:

Start Date: ${req.body.start_date}

End Date: ${req.body.end_date}

Start Location: ${req.body.start_location}

Destination:  ${req.body.destination}

Description/Preferences: ${req.body.description}

Include Restaurants: ${req.body.include_restaurant ? 'yes' : 'no'}

Food Preferences: ${req.body.food_preference}

Kid Friendly: ${req.body.kid_friendly}

Relaxation: ${req.body.relaxation_level}

Budget: ${req.body.budget} (usually 'budget', 'midrange', or 'luxury') Based on the location.
According to the budget, you can adjust the quality of restaurants and activities.

Generate a detailed JSON object containing the following structure:

{
  "trip": {
    "name": "Trip from [Start Location] to [Destination]",
    "description": "[Use input description or generate a summary]",
    "startDate": "[YYYY-MM-DD]",
    "endDate": "[YYYY-MM-DD]"
  },
  "tripDays": [
    {
      "date": "[YYYY-MM-DD]",
      "notes": "Brief note about this day",
      "activities": [
        {
          "activity_type": "sightseeing",
          "name": "Visit Eiffel Tower",
          "description": "See the iconic Eiffel Tower and take photos",
          "location": "Eiffel Tower, Paris",
          "startTime": "10:00",
          "endTime": "12:00",
          "alternatives": [
            {
              "activity_type": "museum",
              "name": "Louvre Museum Visit",
              "description": "Explore world-famous art pieces",
              "location": "Louvre Museum, Paris",
              "startTime": "10:00",
              "endTime": "12:00"
            },
            {
              "activity_type": "relaxing",
              "name": "Seine River Walk",
              "description": "Enjoy a calm riverside stroll",
              "location": "Seine River, Paris",
              "startTime": "10:00",
              "endTime": "12:00"
            }
          ]
        }
        // More activities...
      ]
    }
    // More days...
  ]
}

Requirements:

Match the tripDays to the dates between start and end.

Provide 3–5 realistic activities per day, including at least one top-rated restaurant per day (lunch or dinner) if requested.

Also suggest alternatives for each activity, ensuring they are relevant to the trip's theme (e.g., culture, food, relaxation).

If no preferences are provided, generate a diverse, engaging itinerary combining food, sights, culture, and rest.

Leave all id, userId, tripId, tripDayId, and activity_type_id fields as null.

All timestamps should be in ISO 8601 format.

Output only valid JSON.
    `;
    const generatedContent = await fetchGeminiData(_prompt);
    res.status(200).json({ tripPlan: sanitizeAndParseJson(generatedContent) });
  } catch (error: any) {
    res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

function sanitizeAndParseJson(input: string): any | null {
  try {
    // Remove any markdown code block markers (```json or ```)
    const cleaned = input
      .replace(/```json\s*|```/g, '') // strip code fences
      .replace(/^[\s\r\n]+|[\s\r\n]+$/g, ''); // trim whitespace

    // Parse the cleaned string as JSON
    const parsed = JSON.parse(cleaned);

    return parsed;
  } catch (error) {
    console.error("Failed to parse JSON:", error);
    return null;
  }
}