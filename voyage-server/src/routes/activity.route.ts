import express from 'express';
import * as activityService from '../service/activity.service';

const router = express.Router();

router.get('/', activityService.getAllActivities);
router.get('/:id', activityService.getActivityById);
router.post('/', activityService.createActivity);
router.put('/:id', activityService.updateActivity);
router.delete('/:id', activityService.deleteActivity);

export default router;