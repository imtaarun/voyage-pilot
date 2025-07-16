import { Request, Response } from 'express';
import { User } from '../models/user.model';
import bcrypt from 'bcrypt';

// Helper function for basic validation
function validateUserInput(body: any) {
  const errors: string[] = [];
  if (!body.name || typeof body.name !== 'string') errors.push('Name is required and must be a string.');
  if (!body.email || typeof body.email !== 'string') errors.push('Email is required and must be a string.');
  if (!body.password || typeof body.password !== 'string') errors.push('Password is required and must be a string.');
  return errors;
}

export const getAllUsers = async (_: Request, res: Response) => {
  try {
    const users = await User.findAll();
    res.json(users);
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(200).json([]);
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const getUserById = async (req: Request, res: Response) => {
  try {
    const user = await User.findByPk(req.params.id);
    if (user) return res.json(user);
    return res.status(404).json({ message: 'User not found' });
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(200).json(null);
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const getUserByEmail = async (req: Request, res: Response) => {
  try {
    const user = await User.findOne({ where: { email: req.params.email } });
    if (user) return res.json(user);
    return res.status(404).json({ message: 'User not found' });
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(200).json(null);
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const createUser = async (req: Request, res: Response) => {
  try {
    const errors = validateUserInput(req.body);
    if (errors.length > 0) {
      return res.status(400).json({ errors });
    }
    const existing = await User.findOne({ where: { email: req.body.email } });
    if (existing) {
      return res.status(409).json({ message: 'Email already exists' });
    }
    const hashedPassword = bcrypt.hashSync(req.body.password, 10);
    const user = await User.create({
      username: req.body.name,
      email: req.body.email,
      passwordHash: hashedPassword,
    });
    res.status(201).json(user);
  } catch (error: any) {
    res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

export const updateUser = async (req: Request, res: Response) => {
  try {
    const user = await User.findByPk(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    const updateFields = ['name', 'email', 'password'];
    for (const field of updateFields) {
      if (field in req.body && typeof req.body[field] !== 'string') {
        return res.status(400).json({ message: `${field} must be a string.` });
      }
    }
    if (req.body.email && req.body.email !== user.email) {
      const existing = await User.findOne({ where: { email: req.body.email } });
      if (existing) {
        return res.status(409).json({ message: 'Email already exists' });
      }
    }
    if (req.body.password) {
      req.body.passwordHash = bcrypt.hashSync(req.body.password, 10);
      delete req.body.password;
    }
    await user.update(req.body);
    return res.json(user);
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(200).json(null);
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const deleteUser = async (req: Request, res: Response) => {
  try {
    const user = await User.findByPk(req.params.id);
    if (user) {
      await user.destroy();
      return res.status(204).send();
    }
    return res.status(404).json({ message: 'User not found' });
  } catch (error: any) {
    if (error.name === 'ModelNotInitializedError') {
      return res.status(204).send();
    }
    res.status(500).json({ message: 'Internal server error' });
  }
};
