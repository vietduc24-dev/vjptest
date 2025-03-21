const express = require('express');
const router = express.Router();
const messageController = require('../controllers/message.controller');
const authenticateToken = require('../middlewares/auth.middleware');

router.get('/personal/:username', authenticateToken, messageController.getPersonalMessages);
router.get('/group/:groupId', authenticateToken, messageController.getGroupMessages);

module.exports = router; 