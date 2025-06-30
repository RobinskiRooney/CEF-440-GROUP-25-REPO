// routes/scanRoutes.js - Defines API routes for diagnostic scans

const express = require('express');
const router = express.Router();
const scanController = require('../controllers/scanController');
const authController = require('../controllers/authController'); // For verifyToken middleware

// All scan routes require authentication
router.post('/', authController.verifyToken, scanController.createScan); // Create a new scan record
router.get('/', authController.verifyToken, scanController.getVehicleScans); // Get all scans for a specific vehicle
router.get('/:id', authController.verifyToken, scanController.getScanById); // Get a specific scan record by ID

// Note: Update/Delete operations for scans might be less common or have specific rules.
// You can add them here if needed, applying authController.verifyToken.

module.exports = router;
