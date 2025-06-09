// routes/userRoutes.js - Defines the API routes for user profiles

const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authController = require('../controllers/authController'); // For verifyToken middleware

// All user profile routes require authentication
router.get('/:id', authController.verifyToken, userController.getUserProfile); // Get a specific user's profile by ID
router.put('/:id', authController.verifyToken, userController.updateUserProfile); // Update a user's profile by ID

// Note: For simplicity, we are assuming a user can only access/update their own profile,
// so the :id in the route should typically match req.user.uid in the controller.
// A simpler approach would be:
// router.get('/profile', authController.verifyToken, userController.getUserProfile);
// router.put('/profile', authController.verifyToken, userController.updateUserProfile);
// I've kept :id to be consistent with common REST patterns, but ensure logic verifies ownership.

module.exports = router;
