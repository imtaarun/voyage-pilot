import express from 'express';
import * as userService from '../service/user.service';

const router = express.Router();

router.get('/', userService.getAllUsers);
router.get('/:id', userService.getUserById);
router.get('/email/:email', userService.getUserByEmail);
router.post('/signup', userService.createUser);
router.put('/:id', userService.updateUser);
router.delete('/:id', userService.deleteUser);

export default router;