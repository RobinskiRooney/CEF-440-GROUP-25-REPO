// routes/notificationRoutes.js
const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const authController = require('../controllers/authController');

// All notification routes require authentication
router.use(authController.verifyToken);

// POST /notifications - ADMIN: Create a new notification (potentially for a specific user or global)
// You might add an admin role check here later if needed
router.post('/', notificationController.createNotification);

// GET /notifications - Get all notifications for the authenticated user (including global ones)
router.get('/', notificationController.getMyNotifications);

// PUT /notifications/:id/read - Mark a notification as read
router.put('/:id/read', notificationController.markNotificationAsRead);

// DELETE /notifications/:id - Delete a notification
router.delete('/:id', notificationController.deleteNotification);

module.exports = router;
