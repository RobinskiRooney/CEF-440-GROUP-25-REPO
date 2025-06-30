// routes/authRoutes.js - Defines the API routes for authentication

const express = require('express');
const router = express.Router(); // Create a new router instance
const authController = require('../controllers/authController'); // Import the auth controller

// Define authentication routes
router.post('/register', authController.registerUser); // POST /auth/register to create a new user
router.post('/login', authController.loginUser);       // POST /auth/login to authenticate and get a custom token
router.post('/refresh-token', authController.refreshToken); // POST /auth/refresh-token
router.post('/google-signin', authController.signInWithGoogle)


// Export the router
module.exports = router;
