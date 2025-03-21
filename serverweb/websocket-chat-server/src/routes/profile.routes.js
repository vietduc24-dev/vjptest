const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profile.controller');
const authenticateToken = require('../middlewares/auth.middleware');
const upload = require('../config/multer');

router.get('/', authenticateToken, profileController.getProfile);
router.put('/', authenticateToken, profileController.updateProfile);
router.post('/upload-avatar', authenticateToken, upload.single('avatar'), profileController.uploadAvatar);

module.exports = router; 