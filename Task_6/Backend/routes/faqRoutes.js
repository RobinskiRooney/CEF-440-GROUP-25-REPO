// routes/faqRoutes.js
const express = require('express');
const router = express.Router();
const faqController = require('../controllers/faqController');
const authController = require('../controllers/authController'); // For admin protected routes

// GET /faqs - Get all FAQs (publicly accessible)
router.get('/', faqController.getAllFAQs);

// Routes below this line require authentication (assuming only admins can manage FAQs)
// You would implement an isAdmin check within the controller or as a separate middleware
router.post('/', authController.verifyToken, faqController.createFAQ);
router.put('/:id', authController.verifyToken, faqController.updateFAQ);
router.delete('/:id', authController.verifyToken, faqController.deleteFAQ);

module.exports = router;
