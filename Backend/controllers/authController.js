// controllers/authController.js - Handles user authentication logic

// Import Firebase Admin SDK (already initialized via config/firebase.js, but we need admin object for auth methods)
const admin = require('firebase-admin');
const auth = admin.auth(); // Get the Firebase Admin Auth service
const fetch = require('node-fetch'); // Import node-fetch for making HTTP requests
const dotenv = require('dotenv'); // Dotenv to load environment variables

// Load environment variables from .env file (must be at the top)
dotenv.config();

// Get Firebase Web API Key from environment variables
// This key is different from your Firebase Admin SDK service account key.
// You can find it in your Firebase Console -> Project settings -> General (under "Your apps")
const FIREBASE_WEB_API_KEY = process.env.FIREBASE_WEB_API_KEY;

/**
 * Registers a new user with email and password using Firebase Admin SDK.
 * @param {object} req - The Express request object (expects email, password in body).
 * @param {object} res - The Express response object.
 */
exports.registerUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Basic validation
    if (!email || !password) {
      return res.status(400).send({ message: 'Email and password are required.' });
    }
    if (password.length < 6) { // Firebase requires a minimum password length of 6 characters
        return res.status(400).send({ message: 'Password must be at least 6 characters long.' });
    }

    // Create user in Firebase Authentication
    const userRecord = await auth.createUser({
      email: email,
      password: password,
      emailVerified: false, // You might want to implement email verification later
      disabled: false,
    });

    // Optionally, you can also save some user profile data to Firestore here
    const db = require('../config/firebase'); // If you want to save to Firestore
    await db.collection('users').doc(userRecord.uid).set({
      email: email,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      // Add other user profile fields here
    });

    res.status(201).send({
      message: 'User registered successfully!',
      uid: userRecord.uid,
      email: userRecord.email,
    });

  } catch (error) {
    // Handle Firebase specific errors (e.g., email-already-exists)
    if (error.code === 'auth/email-already-exists') {
      return res.status(409).send({ message: 'Email already in use.', error: error.message });
    }
    console.error('Error registering user:', error);
    res.status(500).send({ message: 'Error registering user', error: error.message });
  }
};

/**
 * Logs in a user with email and password using Firebase Authentication REST API.
 * This directly authenticates with Firebase and returns ID and Refresh tokens.
 * @param {object} req - The Express request object (expects email, password in body).
 * @param {object} res - The Express response object.
 */
exports.loginUser = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).send({ message: 'Email and password are required.' });
        }

        if (!FIREBASE_WEB_API_KEY) {
            console.error('FIREBASE_WEB_API_KEY is not set in environment variables.');
            return res.status(500).send({ message: 'Server configuration error: Firebase Web API Key is missing.' });
        }

        // --- Step 1: Verify Email and Password using Firebase Authentication REST API ---
        const firebaseAuthUrl = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${FIREBASE_WEB_API_KEY}`;

        const firebaseResponse = await fetch(firebaseAuthUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                email: email,
                password: password, // Send password to Firebase REST API for verification
                returnSecureToken: true // Request ID Token and Refresh Token upon success
            }),
        });

        const firebaseData = await firebaseResponse.json();

        if (!firebaseResponse.ok) {
            // Firebase API returned an error (e.g., INVALID_LOGIN_CREDENTIALS, EMAIL_NOT_FOUND)
            const errorMessage = firebaseData.error?.message || 'Authentication failed.';
            console.error('Firebase Auth REST API error:', errorMessage, firebaseData);

            if (errorMessage.includes('EMAIL_NOT_FOUND') || errorMessage.includes('INVALID_PASSWORD') || errorMessage.includes('INVALID_LOGIN_CREDENTIALS')) {
                // Return 401 for invalid credentials
                return res.status(401).send({ message: 'Invalid email or password.' });
            }
            // Catch other potential Firebase errors
            return res.status(500).send({ message: `Firebase login error: ${errorMessage}` });
        }

        // If Firebase REST API login is successful, we get an ID Token, Refresh Token, and UID from Firebase
        const firebaseUid = firebaseData.localId;
        const idToken = firebaseData.idToken;
        const refreshToken = firebaseData.refreshToken;

        // --- Step 2: Return the necessary tokens to the Flutter client ---
        // The customToken is no longer minted here because Flutter will not use signInWithCustomToken.
        // Instead, Flutter will directly use the idToken for authenticated calls to this backend.
        res.status(200).send({
            message: 'User logged in successfully!',
            uid: firebaseUid,
            email: email,
            idToken: idToken,       // The short-lived ID Token
            refreshToken: refreshToken // The long-lived Refresh Token (for manual refreshing if needed)
        });

    } catch (error) {
        console.error('Error logging in user:', error);
        res.status(500).send({ message: 'Error logging in user', error: error.message });
    }
};


/**
 * Handles Google Sign-In by verifying the ID Token sent from the client-side.
 * The client (e.g., Flutter app) should perform the Google Sign-In and send the ID Token to this endpoint.
 * @param {object} req - The Express request object (expects idToken in body from Google Sign-In on client).
 * @param {object} res - The Express response object.
 */
exports.signInWithGoogle = async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).send({ message: 'Google ID Token is required.' });
    }

    // Verify the ID token using the Firebase Admin SDK
    // This confirms the token is valid and retrieves user information.
    const decodedToken = await auth.verifyIdToken(idToken);

    // decodedToken contains user information like uid, email, name, picture, etc.
    const uid = decodedToken.uid;
    const email = decodedToken.email;

    // You can optionally create or update a user record in your database (e.g., Firestore)
    // based on the Google user's information here.
    // Example: Check if user exists, if not, create them.
    const db = require('../config/firebase');
    const userRef = db.collection('users').doc(uid);
    const doc = await userRef.get();
    if (!doc.exists) {
      await userRef.set({
        email: email,
        displayName: decodedToken.name,
        photoURL: decodedToken.picture,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        // ... other fields from decodedToken as needed
      });
    }

    res.status(200).send({
      message: 'User authenticated with Google successfully!',
      uid: uid,
      email: email,
      // You don't send the Google ID token back to the client directly.
      // The client already has it or can generate a new one if needed.
      // If your client needs a "session token" from your backend, you'd mint a custom token here,
      // but usually, the client will just use the verified ID token for subsequent requests.
    });

  } catch (error) {
    console.error('Error verifying Google ID token:', error);
    if (error.code === 'auth/invalid-credential' || error.code === 'auth/argument-error' || error.code === 'auth/id-token-expired') {
        return res.status(401).send({ message: 'Invalid or expired Google ID Token.', error: error.message });
    }
    res.status(500).send({ message: 'Error during Google authentication backend verification', error: error.message });
  }
};


/**
 * Refreshes an expired Firebase ID Token using the Refresh Token.
 * @param {object} req - The Express request object (expects refreshToken in body).
 * @param {object} res - The Express response object.
 */
exports.refreshToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(400).send({ message: 'Refresh token is required.' });
    }
    if (!FIREBASE_WEB_API_KEY) {
      console.error('FIREBASE_WEB_API_KEY is not set in environment variables.');
      return res.status(500).send({ message: 'Server configuration error: Firebase Web API Key is missing.' });
    }

    const refreshUrl = `https://securetoken.googleapis.com/v1/token?key=${FIREBASE_WEB_API_KEY}`;
    const firebaseResponse = await fetch(refreshUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ grant_type: 'refresh_token', refresh_token: refreshToken }),
    });
    const firebaseData = await firebaseResponse.json();

    if (!firebaseResponse.ok) {
      const errorMessage = firebaseData.error?.message || 'Token refresh failed.';
      console.error('Firebase Refresh Token REST API error:', errorMessage, firebaseData);
      if (errorMessage.includes('INVALID_REFRESH_TOKEN') || errorMessage.includes('TOKEN_EXPIRED')) {
        return res.status(401).send({ message: 'Session expired. Please log in again.' });
      }
      return res.status(500).send({ message: `Token refresh error: ${errorMessage}` });
    }

    res.status(200).send({
      idToken: firebaseData.id_token,
      refreshToken: firebaseData.refresh_token || refreshToken, // Firebase returns a new refresh token sometimes
      message: 'ID Token refreshed successfully.'
    });
  } catch (error) {
    console.error('Error refreshing token:', error);
    res.status(500).send({ message: 'Error refreshing token', error: error.message });
  }
};


/**
 * Middleware to verify Firebase ID Tokens for protected routes.
 * It expects an ID Token in the 'Authorization' header as 'Bearer <token>'.
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 * @param {function} next - The next middleware function.
 */
exports.verifyToken = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).send({ message: 'No authentication token provided.' });
  }

  const idToken = authHeader.split('Bearer ')[1];

  try {
    const decodedToken = await auth.verifyIdToken(idToken);
    req.user = decodedToken; // Attach decoded token to request for downstream use (e.g., req.user.uid)
    next(); // Proceed to the next middleware or route handler
  } catch (error) {
    console.error('Error verifying ID token:', error);
    if (error.code === 'auth/id-token-expired') {
      return res.status(401).send({ message: 'Authentication token expired.', error: error.message });
    }
    res.status(403).send({ message: 'Invalid or unauthorized token.', error: error.message });
  }
};