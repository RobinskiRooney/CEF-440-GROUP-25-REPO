// routes/itemRoutes.js - Defines the API routes for item operations

const express = require('express');
const router = express.Router();
const itemController = require('../controllers/itemController');
const authController = require('../controllers/authController'); // To use verifyToken middleware

// Define item routes
// Protected routes (require authentication)
router.post('/', authController.verifyToken, itemController.createItem);
router.put('/:id', authController.verifyToken, itemController.updateItem);
router.delete('/:id', authController.verifyToken, itemController.deleteItem);

// Public routes (no authentication required for these examples)
router.get('/', itemController.getAllItems);
router.get('/:id', itemController.getItemById);

// Export the router
module.exports = router;
