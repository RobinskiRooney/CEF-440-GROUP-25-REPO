// routes/historyRoutes.js
const express = require('express');
const router = express.Router();
const historyController = require('../controllers/historyController');
const authController = require('../controllers/authController'); // For token verification

// All history routes require authentication
router.use(authController.verifyToken);

// POST /history - Create a new history entry for the authenticated user
router.post('/', historyController.createHistoryEntry);

// GET /history - Get all history entries for the authenticated user
router.get('/', historyController.getMyHistory);

// GET /history/:id - Get a specific history entry by ID for the authenticated user
router.get('/:id', historyController.getHistoryEntryById);

// DELETE /history/:id - Delete a specific history entry for the authenticated user
router.delete('/:id', historyController.deleteHistoryEntry);

module.exports = router;
