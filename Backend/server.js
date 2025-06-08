// server.js - Main application file (Updated to include Auth routes)

// Import necessary modules
const express = require('express'); // Express.js for creating the server and routing
const bodyParser = require('body-parser'); // Body-parser to parse incoming request bodies
const cors = require('cors'); // CORS middleware to enable cross-origin requests
const dotenv = require('dotenv'); // Dotenv to load environment variables

// Load environment variables from .env file (must be at the top)
dotenv.config();

// Import routes
const itemRoutes = require('./routes/itemRoutes'); // Corrected path to lowercase 'routes'
const authRoutes = require('./routes/authRoutes'); // New: Import authentication routes

// Import the database configuration (this also initializes Firebase Admin SDK)
// Note: We don't directly use 'db' here, but requiring it ensures Firebase is initialized
require('./config/firebase'); // Just require to ensure initialization happens

// --- Express App Setup ---
const app = express(); // Create an Express application instance
const port = process.env.PORT || 3000; // Define the port, use environment variable for Render

// Middleware
app.use(cors()); // Enable CORS for all routes
app.use(bodyParser.json()); // Parse JSON request bodies

// --- API Endpoints ---

// Root route - simple check
app.get('/', (req, res) => {
  res.status(200).send('Firebase Node.js Backend is running!');
});

// Authentication routes
app.use('/auth', authRoutes); // Mount the authentication routes under /auth prefix

// Item routes
app.use('/items', itemRoutes); // Mount the item routes under /items prefix

// --- Start the Server ---
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
