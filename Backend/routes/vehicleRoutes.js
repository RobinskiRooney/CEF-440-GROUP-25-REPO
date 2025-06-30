// routes/vehicleRoutes.js - Defines API routes for vehicle management

const express = require('express');
const router = express.Router();
const vehicleController = require('../controllers/vehicleController');
const authController = require('../controllers/authController'); // For verifyToken middleware

// All vehicle routes require authentication
router.post('/', authController.verifyToken, vehicleController.createVehicle); // Create a new vehicle
router.get('/', authController.verifyToken, vehicleController.getUserVehicles); // Get all vehicles for the authenticated user
router.get('/:id', authController.verifyToken, vehicleController.getVehicleById); // Get a specific vehicle by ID
router.put('/:id', authController.verifyToken, vehicleController.updateVehicle); // Update a vehicle by ID
router.delete('/:id', authController.verifyToken, vehicleController.deleteVehicle); // Delete a vehicle by ID

module.exports = router;
