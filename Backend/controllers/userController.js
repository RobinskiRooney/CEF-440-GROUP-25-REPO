// controllers/userController.js - Handles user profile data and admin user management

const db = require('../config/firebase'); // Import Firestore database instance
const admin = require('firebase-admin'); // Import Firebase Admin SDK
const path = require('path');
const fs = require('fs');

/**
 * Gets a user's profile data from Firestore.
 * User must be authenticated to access their own profile.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 */
exports.getUserProfile = async (req, res) => {
  try {
    const userId = req.user.uid; // User ID from verified token (set by verifyToken middleware)

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
 * Accepts multipart/form-data for image upload.
 * @param {object} req - Express request object (expects profile data in body).
 * @param {object} res - Express response object.
 */
exports.updateUserProfile = async (req, res) => {
  try {
    const userId = req.user.uid; // User ID from verified token
    const { name, contact, location, car_model } = req.body;

    let imageUrl = req.body.imageUrl || '';
    if (req.file) {
      // Save the file and set the imageUrl
      const ext = path.extname(req.file.originalname);
      const fileName = `${userId}_${Date.now()}${ext}`;
      const uploadPath = path.join(__dirname, '../uploads', fileName);
      fs.writeFileSync(uploadPath, req.file.buffer);
      imageUrl = `/uploads/${fileName}`;
    }

    const updates = {
      name: name || '',
      contact: contact || '',
      location: location || '',
      car_model: car_model || '',
      imageUrl: imageUrl|| '',
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    // Use set with merge: true to create if not exists, or update if exists
    await db.collection('users').doc(userId).set(updates, { merge: true });

    res.status(200).send({ message: 'User profile updated successfully!', imageUrl });
  } catch (error) {
    console.error('Error updating user profile:', error);
    res.status(500).send({ message: 'Error updating user profile', error: error.message });
  }
};

/**
 * Deletes a user from Firebase Authentication and optionally their Firestore profile.
 * This endpoint requires admin privileges.
 * @param {object} req - Express request object (expects targetUserId in body).
 * @param {object} res - Express response object.
 */
exports.deleteUser = async (req, res) => {
  try {
    const { targetUserId } = req.body; // The UID of the user to be deleted
    // Admin check is done by the adminMiddleware before this function is called

    if (!targetUserId) {
      return res.status(400).send({ message: 'Target user ID is required for deletion.' });
    }

    // Optional: Prevent an admin from deleting themselves via this endpoint
    if (req.user.uid === targetUserId) {
      return res.status(400).send({ message: 'An administrator cannot delete their own account via this endpoint.' });
    }

    // Delete user from Firebase Authentication
    await admin.auth().deleteUser(targetUserId);

    // Optional: Delete user's profile data from Firestore as well
    await db.collection('users').doc(targetUserId).delete(); // Deletes the document with the matching UID

    res.status(200).send({ message: `User ${targetUserId} deleted successfully.` });
  } catch (error) {
    console.error('Error deleting user:', error);
    if (error.code === 'auth/user-not-found') {
      return res.status(404).send({ message: 'User to be deleted not found.', error: error.message });
    }
    res.status(500).send({ message: 'Error deleting user', error: error.message });
  }
};

/**
 * Fetches a list of all users from Firebase Authentication.
 * This endpoint requires admin privileges.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 */

exports.getAllUserProfile = async (req, res) => {
  try {
    // Implement filtering/sorting/proximity search here if needed
    // For simplicity, fetching all for now
    const snapshot = await db.collection('userProfile').orderBy('name').get();
    const usersProfile = [];
    snapshot.forEach(doc => {
      usersProfile.push({ id: doc.id, ...doc.data() });
    });

    res.status(200).send(usersProfile);
  } catch (error) {
    console.error('Error fetching mechanics:', error);
    res.status(500).send({ message: 'Error fetching mechanics', error: error.message });
  }
};

/**
 * Checks if the authenticated user has admin privileges.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 */
exports.fetchUserRole = async (req, res) => {
  try {
    // req.user contains the decoded ID token, which includes custom claims
    const isAdmin = req.user.admin === true; // Assuming 'admin: true' custom claim
    res.status(200).send({ isAdmin: isAdmin });
  } catch (error) {
    console.error('Error fetching user role:', error);
    res.status(500).send({ message: 'Error fetching user role', error: error.message });
  }
};
