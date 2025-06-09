// controllers/vehicleController.js - Handles vehicle data

const db = require('../config/firebase');
const admin = require('firebase-admin');

/**
 * Creates a new vehicle for the authenticated user.
 * @param {object} req - Express request object (expects vehicle data in body).
 * @param {object} res - Express response object.
 */
exports.createVehicle = async (req, res) => {
  try {
    const { make, model, year, VIN, nickname } = req.body;
    const ownerUid = req.user.uid; // Owner's UID from authenticated token

    if (!make || !model || !year || !VIN || !nickname) {
      return res.status(400).send({ message: 'Missing required vehicle fields: make, model, year, VIN, nickname' });
    }

    // Check if VIN already exists (optional, but good practice for unique vehicles)
    const existingVehicle = await db.collection('vehicles').where('VIN', '==', VIN).limit(1).get();
    if (!existingVehicle.empty) {
      return res.status(409).send({ message: 'Vehicle with this VIN already exists.' });
    }

    const newVehicleRef = await db.collection('vehicles').add({
      owner_uid: ownerUid,
      make,
      model,
      year: parseInt(year), // Ensure year is a number
      VIN,
      nickname,
      health_status: 'Unknown', // Default status
      last_scan_date: null,     // Will be updated after a scan
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(201).send({ message: 'Vehicle added successfully', id: newVehicleRef.id });
  } catch (error) {
    console.error('Error creating vehicle:', error);
    res.status(500).send({ message: 'Error creating vehicle', error: error.message });
  }
};

/**
 * Gets all vehicles for the authenticated user.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 */
exports.getUserVehicles = async (req, res) => {
  try {
    const ownerUid = req.user.uid; // Owner's UID from authenticated token

    const snapshot = await db.collection('vehicles')
                             .where('owner_uid', '==', ownerUid)
                             .orderBy('createdAt', 'desc')
                             .get();

    const vehicles = [];
    snapshot.forEach(doc => {
      vehicles.push({ id: doc.id, ...doc.data() });
    });

    res.status(200).send(vehicles);
  } catch (error) {
    console.error('Error fetching user vehicles:', error);
    res.status(500).send({ message: 'Error fetching user vehicles', error: error.message });
  }
};

/**
 * Gets a single vehicle by ID. User must be the owner.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 */
exports.getVehicleById = async (req, res) => {
  try {
    const vehicleId = req.params.id;
    const ownerUid = req.user.uid;

    const vehicleDoc = await db.collection('vehicles').doc(vehicleId).get();

    if (!vehicleDoc.exists) {
      return res.status(404).send({ message: 'Vehicle not found.' });
    }
    if (vehicleDoc.data().owner_uid !== ownerUid) {
      return res.status(403).send({ message: 'Permission denied: Not your vehicle.' });
    }

    res.status(200).send({ id: vehicleDoc.id, ...vehicleDoc.data() });
  } catch (error) {
    console.error('Error fetching vehicle by ID:', error);
    res.status(500).send({ message: 'Error fetching vehicle', error: error.message });
  }
};

/**
 * Updates a vehicle's information. User must be the owner.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 */
exports.updateVehicle = async (req, res) => {
  try {
    const vehicleId = req.params.id;
    const ownerUid = req.user.uid;
    const updates = req.body;

    if (Object.keys(updates).length === 0) {
      return res.status(400).send({ message: 'No update data provided.' });
    }

    const vehicleRef = db.collection('vehicles').doc(vehicleId);
    const vehicleDoc = await vehicleRef.get();

    if (!vehicleDoc.exists) {
      return res.status(404).send({ message: 'Vehicle not found.' });
    }
    if (vehicleDoc.data().owner_uid !== ownerUid) {
      return res.status(403).send({ message: 'Permission denied: Not your vehicle.' });
    }

    await vehicleRef.update({
      ...updates,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(200).send({ message: 'Vehicle updated successfully.' });
  } catch (error) {
    console.error('Error updating vehicle:', error);
    res.status(500).send({ message: 'Error updating vehicle', error: error.message });
  }
};

/**
 * Deletes a vehicle. User must be the owner.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 */
exports.deleteVehicle = async (req, res) => {
  try {
    const vehicleId = req.params.id;
    const ownerUid = req.user.uid;

    const vehicleRef = db.collection('vehicles').doc(vehicleId);
    const vehicleDoc = await vehicleRef.get();

    if (!vehicleDoc.exists) {
      return res.status(404).send({ message: 'Vehicle not found.' });
    }
    if (vehicleDoc.data().owner_uid !== ownerUid) {
      return res.status(403).send({ message: 'Permission denied: Not your vehicle.' });
    }

    await vehicleRef.delete();
    res.status(200).send({ message: 'Vehicle deleted successfully.' });
  } catch (error) {
    console.error('Error deleting vehicle:', error);
    res.status(500).send({ message: 'Error deleting vehicle', error: error.message });
  }
};
