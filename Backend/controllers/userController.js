// controllers/userController.js - Handles user profile data

const db = require('../config/firebase'); // Import Firestore database instance
const admin = require('firebase-admin');

/**
 * Gets a user's profile data from Firestore.
 * User must be authenticated to access their own profile.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 */
exports.getUserProfile = async (req, res) => {
  try {
    const userId = req.user.uid; // User ID from verified token

    const userDoc = await db.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      // If no profile exists, return a default/empty profile or 404
      return res.status(404).send({ message: 'User profile not found. Consider creating it.' });
    }

    res.status(200).send({ id: userDoc.id, ...userDoc.data() });
  } catch (error) {
    console.error('Error fetching user profile:', error);
    res.status(500).send({ message: 'Error fetching user profile', error: error.message });
  }
};

/**
 * Creates or updates a user's profile data in Firestore.
 * User must be authenticated.
 * @param {object} req - Express request object (expects profile data in body).
 * @param {object} res - Express response object.
 */
exports.updateUserProfile = async (req, res) => {
  try {
    const userId = req.user.uid; // User ID from verified token
    const { name, contact, location, car_model } = req.body;

    const updates = {
      name: name || '',
      contact: contact || '',
      location: location || '',
      car_model: car_model || '',
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    // Use set with merge: true to create if not exists, or update if exists
    await db.collection('users').doc(userId).set(updates, { merge: true });

    res.status(200).send({ message: 'User profile updated successfully!' });
  } catch (error) {
    console.error('Error updating user profile:', error);
    res.status(500).send({ message: 'Error updating user profile', error: error.message });
  }
};
