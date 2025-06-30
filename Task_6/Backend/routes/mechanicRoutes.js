// routes/mechanicRoutes.js - Defines API routes for mechanic directory

const express = require('express');
const router = express.Router();
const mechanicController = require('../controllers/mechanicController');
const authController = require('../controllers/authController'); // For verifyToken middleware (if needed for some actions)

// Public routes (no authentication needed for viewing mechanics)
router.get('/', mechanicController.getAllMechanics); // Get all mechanics
router.get('/:id', mechanicController.getMechanicById); // Get a specific mechanic by ID

// Protected routes (e.g., for admin to create/update/delete mechanics)
// You might want to add role-based authentication here
router.post('/', authController.verifyToken, mechanicController.createMechanic); // Create a new mechanic
router.put('/:id', authController.verifyToken, mechanicController.updateMechanic); // Update a mechanic
router.delete('/:id', authController.verifyToken, mechanicController.deleteMechanic); // Delete a mechanic

module.exports = router;
