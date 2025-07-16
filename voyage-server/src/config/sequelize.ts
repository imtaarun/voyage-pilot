import { Sequelize } from 'sequelize-typescript';
import * as dotenv from 'dotenv';
import config from './database';
import { User } from '../models/user.model';
import { Trip } from '../models/trip.model';
import { TripDay } from '../models/trip-day.model';
import { Activity } from '../models/activity.model';

dotenv.config(); 

const env = process.env.NODE_ENV || 'development';
const currentConfig = config[env];

if (!currentConfig) {
  throw new Error(`Sequelize configuration not found for environment: ${env}`);
}

// Create the Sequelize instance
const sequelize = new Sequelize({
  ...currentConfig,
  models: [User, Trip, TripDay, Activity],
  logging: false,
});

// Authenticate and sync the database
async function connectDatabase() {
  try {
    await sequelize.authenticate();
    console.log('Database connection has been established successfully.');
  } catch (error) {
    console.error('Unable to connect to the database or sync models:', error);
    process.exit(1); 
  }
}
connectDatabase();

export { sequelize }; 
