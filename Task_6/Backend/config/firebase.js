// config/firebase.js
const admin = require('firebase-admin');

// Check if Firebase app is already initialized to prevent re-initialization errors
if (admin.apps.length === 0) {
  // Read the Firebase service account key from environment variable
  // This environment variable should be set on Render with the FULL JSON string content
  const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_KEY_JSON;

  if (!serviceAccountJson) {
    console.error("FIREBASE_SERVICE_ACCOUNT_KEY_JSON environment variable is not set.");
    // Exit or throw an error, as Firebase Admin SDK cannot initialize without credentials
    process.exit(1);
  }

  let serviceAccount;
  try {
    // Parse the JSON string from the environment variable
    serviceAccount = JSON.parse(serviceAccountJson);
  } catch (e) {
    console.error("Error parsing FIREBASE_SERVICE_ACCOUNT_KEY_JSON:", e);
    process.exit(1);
  }

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    // If you use Realtime Database or Storage, add databaseURL or storageBucket here:
    // databaseURL: "https://<DATABASE_NAME>.firebaseio.com",
    // storageBucket: "gs://<BUCKET_NAME>.appspot.com"
  });

  console.log('Firebase Admin SDK initialized successfully via environment variable.');
} else {
  console.log('Firebase Admin SDK already initialized.');
}

// Export the Firestore database instance
const db = admin.firestore();

module.exports = db;