// controllers/scanController.js - Handles diagnostic scan data

const db = require('../config/firebase');
const admin = require('firebase-admin');

/**
 * Creates a new diagnostic scan record.
 * Assumes req.user.uid is available from authController.verifyToken middleware.
 * @param {object} req - Express request object (expects scan data in body).
 * @param {object} res - Express response object.
 */
exports.createScan = async (req, res) => {
  try {
    const { vehicle_id, scan_type, summary, status, // Common fields
            light_image_url, identified_light_name, light_explanation, // Dashboard Light specific
            recorded_sound_url, sound_diagnosis_result, potential_causes, // Engine Sound specific
            dtc_codes, freeze_frame_data // OBD specific
          } = req.body;

    const createdByUid = req.user.uid;

    if (!vehicle_id || !scan_type || !summary || !status) {
      return res.status(400).send({ message: 'Missing common required fields for scan: vehicle_id, scan_type, summary, status' });
    }

    // Optional: Verify vehicle_id belongs to createdByUid
    const vehicleDoc = await db.collection('vehicles').doc(vehicle_id).get();
    if (!vehicleDoc.exists || vehicleDoc.data().owner_uid !== createdByUid) {
      return res.status(403).send({ message: 'Permission denied: Vehicle does not exist or does not belong to user.' });
    }

    const newScanData = {
      vehicle_id,
      scan_date_time: admin.firestore.FieldValue.serverTimestamp(),
      scan_type,
      summary,
      status,
      created_by_uid: createdByUid,
    };

    // Add type-specific fields
    if (scan_type === 'DASHBOARD_LIGHT_SCAN') {
      Object.assign(newScanData, {
        light_image_url: light_image_url || null,
        identified_light_name: identified_light_name || null,
        light_explanation: light_explanation || null,
      });
    } else if (scan_type === 'ENGINE_SOUND_DIAGNOSIS') {
      Object.assign(newScanData, {
        recorded_sound_url: recorded_sound_url || null,
        sound_diagnosis_result: sound_diagnosis_result || null,
        potential_causes: potential_causes || [],
      });
    } else if (scan_type === 'OBD_SCAN') {
      Object.assign(newScanData, {
        dtc_codes: dtc_codes || [],
        freeze_frame_data: freeze_frame_data || {},
      });
    }

    const newScanRef = await db.collection('scans').add(newScanData);

    // Update vehicle's last_scan_date
    await db.collection('vehicles').doc(vehicle_id).update({
      last_scan_date: admin.firestore.FieldValue.serverTimestamp(),
      health_status: status // Update health status based on latest scan
    });

    res.status(201).send({ message: 'Scan record created successfully', id: newScanRef.id });
  } catch (error) {
    console.error('Error creating scan record:', error);
    res.status(500).send({ message: 'Error creating scan record', error: error.message });
  }
};

/**
 * Gets all diagnostic scan records for a specific vehicle (owned by the authenticated user).
 * @param {object} req - Express request object (expects vehicle_id as query param).
 * @param {object} res - Express response object.
 */
exports.getVehicleScans = async (req, res) => {
  try {
    const vehicleId = req.query.vehicle_id;
    const createdByUid = req.user.uid;

    if (!vehicleId) {
      return res.status(400).send({ message: 'Vehicle ID is required.' });
    }

    // Optional: Verify vehicle_id belongs to createdByUid
    const vehicleDoc = await db.collection('vehicles').doc(vehicleId).get();
    if (!vehicleDoc.exists || vehicleDoc.data().owner_uid !== createdByUid) {
      return res.status(403).send({ message: 'Permission denied: Vehicle does not exist or does not belong to user.' });
    }

    const snapshot = await db.collection('scans')
                             .where('vehicle_id', '==', vehicleId)
                             .where('created_by_uid', '==', createdByUid) // Ensure user owns the scan
                             .orderBy('scan_date_time', 'desc')
                             .get();

    const scans = [];
    snapshot.forEach(doc => {
      scans.push({ id: doc.id, ...doc.data() });
    });

    res.status(200).send(scans);
  } catch (error) {
    console.error('Error fetching vehicle scans:', error);
    res.status(500).send({ message: 'Error fetching vehicle scans', error: error.message });
  }
};

/**
 * Gets a single diagnostic scan record by ID. User must own the associated vehicle.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 */
exports.getScanById = async (req, res) => {
  try {
    const scanId = req.params.id;
    const createdByUid = req.user.uid;

    const scanDoc = await db.collection('scans').doc(scanId).get();

    if (!scanDoc.exists) {
      return res.status(404).send({ message: 'Scan record not found.' });
    }

    // Verify user owns the vehicle associated with the scan
    const vehicleDoc = await db.collection('vehicles').doc(scanDoc.data().vehicle_id).get();
    if (!vehicleDoc.exists || vehicleDoc.data().owner_uid !== createdByUid) {
      return res.status(403).send({ message: 'Permission denied: You do not have access to this scan.' });
    }

    res.status(200).send({ id: scanDoc.id, ...scanDoc.data() });
  } catch (error) {
    console.error('Error fetching scan by ID:', error);
    res.status(500).send({ message: 'Error fetching scan', error: error.message });
  }
};
