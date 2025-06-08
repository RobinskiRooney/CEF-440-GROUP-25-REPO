// config/firebase.js - Firebase Initialization and Database Export

// Import Firebase Admin SDK
const admin = require('firebase-admin');

// IMPORTANT: Replace '../serviceAccountKey.json' with the actual path
// to your Firebase service account key file.
// You can download this file from your Firebase project settings -> Service accounts.
// For production, consider using environment variables for the service account key content.
const serviceAccount = require('../FirebaseKeys/autofix-car-firebase-adminsdk.json'); // Path relative to this config file

// Initialize Firebase Admin SDK if not already initialized
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

// Get a reference to the Firestore database
const db = admin.firestore();

// Export the Firestore database instance
module.exports = db;
