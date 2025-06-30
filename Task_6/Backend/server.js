// server.js - Main application file

// Load environment variables from .env file FIRST!
const dotenv = require('dotenv');
dotenv.config();

// Import necessary modules
const express = require('express'); // Express.js for creating the server and routing
const bodyParser = require('body-parser'); // Body-parser to parse incoming request bodies
const cors = require('cors'); // CORS middleware to enable cross-origin requests

// Import Firebase Admin SDK configuration (this initializes Firebase)
require('./config/firebase');

// Import all custom routes
const itemRoutes = require('./routes/itemRoutes');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const vehicleRoutes = require('./routes/vehicleRoutes');
const scanRoutes = require('./routes/scanRoutes');
const mechanicRoutes = require('./routes/mechanicRoutes');
const historyRoutes = require('./routes/historyRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const faqRoutes = require('./routes/faqRoutes');


// --- Express App Setup ---
const app = express(); // Create an Express application instance
const port = process.env.PORT || 3000; // Define the port, use environment variable for Render or default to 3000

// Middleware
app.use(cors()); // Enable CORS for all routes (important for Flutter web/mobile communication)
app.use(bodyParser.json()); // Parse JSON request bodies

// --- API Endpoints ---

// Root route - simple check to ensure the backend is running
app.get('/', (req, res) => {
  res.status(200).send('Firebase Node.js Backend is running!');
});

// Mount all route modules under their respective base paths
app.use('/auth', authRoutes);         // Authentication routes (login, register, refresh-token)
app.use('/users', userRoutes);        // User profile routes
app.use('/vehicles', vehicleRoutes);  // Vehicle management routes
app.use('/scans', scanRoutes);        // Diagnostic scan routes
app.use('/mechanics', mechanicRoutes); // Mechanic directory routes
app.use('/history', historyRoutes);       // History management routes
app.use('/notifications', notificationRoutes); // Notification management routes
app.use('/faqs', faqRoutes);          // FAQs and Tips routes
app.use('/items', itemRoutes);        // Generic item routes (ensure this is after auth as it might use auth middleware)


// --- Start the Server ---
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
