// controllers/mechanicController.js - Handles mechanic directory data

const db = require('../config/firebase');
const admin = require('firebase-admin');

/**
 * Creates a new mechanic entry. (Could be an admin-only function).
 * @param {object} req - Express request object (expects mechanic data in body).
 * @param {object} res - Express response object.
 */
exports.createMechanic = async (req, res) => {
  try {
    const { name, address, phone, email, website, rating, verification_status, latitude, longitude, specialties } = req.body;

    if (!name || !address || !phone || !latitude || !longitude) {
      return res.status(400).send({ message: 'Missing required mechanic fields: name, address, phone, latitude, longitude' });
    }

    const newMechanicRef = await db.collection('mechanics').add({
      name,
      address,
      phone,
      email: email || null,
      website: website || null,
      rating: rating || 0, // Default rating
      verification_status: verification_status || 'Unverified', // Default status
      latitude,
      longitude,
      specialties: specialties || [],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(201).send({ message: 'Mechanic added successfully', id: newMechanicRef.id });
  } catch (error) {
    console.error('Error creating mechanic:', error);
    res.status(500).send({ message: 'Error creating mechanic', error: error.message });
  }
};

/**
 * Gets all mechanics, optionally filtered by location or search term.
 * This can be a public endpoint.
 * @param {object} req - Express request object (optional query params for search/location).
 * @param {object} res - Express response object.
 */
exports.getAllMechanics = async (req, res) => {
  try {
    // Implement filtering/sorting/proximity search here if needed
    // For simplicity, fetching all for now
    const snapshot = await db.collection('mechanics').orderBy('name').get();
    const mechanics = [];
    snapshot.forEach(doc => {
      mechanics.push({ id: doc.id, ...doc.data() });
    });

    res.status(200).send(mechanics);
  } catch (error) {
    console.error('Error fetching mechanics:', error);
    res.status(500).send({ message: 'Error fetching mechanics', error: error.message });
  }
};

/**
 * Gets a single mechanic by ID. This can be a public endpoint.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 */
exports.getMechanicById = async (req, res) => {
  try {
    const mechanicId = req.params.id;
    const mechanicDoc = await db.collection('mechanics').doc(mechanicId).get();

    if (!mechanicDoc.exists) {
      return res.status(404).send({ message: 'Mechanic not found.' });
    }

    res.status(200).send({ id: mechanicDoc.id, ...mechanicDoc.data() });
  } catch (error) {
    console.error('Error fetching mechanic by ID:', error);
    res.status(500).send({ message: 'Error fetching mechanic', error: error.message });
  }
};

/**
 * Updates a mechanic's information. (Could be an admin-only or specific mechanic-only function).
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 */
exports.updateMechanic = async (req, res) => {
  try {
    const mechanicId = req.params.id;
    const updates = req.body;

    if (Object.keys(updates).length === 0) {
      return res.status(400).send({ message: 'No update data provided.' });
    }

    await db.collection('mechanics').doc(mechanicId).update({
      ...updates,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(200).send({ message: 'Mechanic updated successfully.' });
  } catch (error) {
    console.error('Error updating mechanic:', error);
    res.status(500).send({ message: 'Error updating mechanic', error: error.message });
  }
};

/**
 * Deletes a mechanic entry. (Likely an admin-only function).
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 */
exports.deleteMechanic = async (req, res) => {
  try {
    const mechanicId = req.params.id;
    await db.collection('mechanics').doc(mechanicId).delete();
    res.status(200).send({ message: 'Mechanic deleted successfully.' });
  } catch (error) {
    console.error('Error deleting mechanic:', error);
    res.status(500).send({ message: 'Error deleting mechanic', error: error.message });
  }
};
