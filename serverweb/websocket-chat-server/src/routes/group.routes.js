const express = require('express');
const router = express.Router();
const groupController = require('../controllers/group.controller');
const authenticateToken = require('../middlewares/auth.middleware');

router.post('/', authenticateToken, groupController.createGroup);
router.get('/', authenticateToken, groupController.getGroups);
router.get('/:groupId', authenticateToken, groupController.getGroupInfo);
router.post('/:groupId/members', authenticateToken, groupController.addMember);
router.delete('/:groupId/members/:username', authenticateToken, groupController.removeMember);
router.delete('/:groupId/leave', authenticateToken, groupController.leaveGroup);

module.exports = router; 