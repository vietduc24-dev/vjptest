const express = require('express');
const router = express.Router();
const friendController = require('../controllers/friend.controller');
const authenticateToken = require('../middlewares/auth.middleware');

router.get('/', authenticateToken, friendController.getFriends);
router.get('/requests', authenticateToken, friendController.getFriendRequests);
router.post('/requests', authenticateToken, friendController.sendFriendRequest);
router.put('/requests/:username/accept', authenticateToken, friendController.acceptFriendRequest);
router.delete('/requests/:username', authenticateToken, friendController.rejectFriendRequest);

module.exports = router; 