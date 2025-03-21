const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const authenticateToken = require('../middlewares/auth.middleware');

router.get('/search', authenticateToken, userController.searchUsers);

module.exports = router; 