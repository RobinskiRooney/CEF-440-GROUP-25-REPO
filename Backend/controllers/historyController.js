// controllers/historyController.js
const admin = require('firebase-admin');
const db = require('../config/firebase');

// Create a new history entry
exports.createHistoryEntry = async (req, res) => {
  try {
    const { type, title, description, details } = req.body;
    const userId = req.user.uid; // Get UID from authenticated user

    if (!type || !title || !description) {
      return res.status(400).send({ message: 'Type, title, and description are required for history entry.' });
    }

    const newEntryRef = await db.collection('history').add({
      user_id: userId,
      type,
      title,
      description,
      details: details || {}, // Ensure details is an object
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Fetch the newly created document to get the server-set timestamp for the response
    const newEntryDoc = await newEntryRef.get();
    const entryData = newEntryDoc.data();

    res.status(201).send({
      id: newEntryRef.id,
      user_id: userId,
      type,
      title,
      description,
      details: entryData.details, // Use the actual data from Firestore
      timestamp: entryData.timestamp ? entryData.timestamp.toDate().toISOString() : null, // Convert Firestore Timestamp to ISO 8601 string
    });
  } catch (error) {
    console.error('Error creating history entry:', error);
    res.status(500).send({ message: 'Error creating history entry', error: error.message });
  }
};

// Get all history entries for the authenticated user
exports.getMyHistory = async (req, res) => {
  try {
    const userId = req.user.uid; // Get UID from authenticated user
    const snapshot = await db.collection('history')
      .where('user_id', '==', userId)
      .orderBy('timestamp', 'desc') // Order by latest first
      .get();

    const history = [];
    snapshot.forEach(doc => {
      const data = doc.data();
      history.push({
        id: doc.id,
        ...data,
        timestamp: data.timestamp ? data.timestamp.toDate().toISOString() : null, // Convert Firestore Timestamp to ISO 8601 string
      });
    });

    res.status(200).send(history);
  } catch (error) {
    console.error('Error fetching user history:', error);
    res.status(500).send({ message: 'Error fetching user history', error: error.message });
  }
};

// Get a specific history entry by ID (ensure it belongs to the user)
exports.getHistoryEntryById = async (req, res) => {
  try {
    const entryId = req.params.id;
    const userId = req.user.uid; // Get UID from authenticated user

    const entryDoc = await db.collection('history').doc(entryId).get();

    if (!entryDoc.exists) {
      return res.status(404).send({ message: 'History entry not found.' });
    }

    // Ensure the entry belongs to the authenticated user
    if (entryDoc.data().user_id !== userId) {
      return res.status(403).send({ message: 'Unauthorized access to history entry.' });
    }

    const data = entryDoc.data();
    res.status(200).send({
      id: entryDoc.id,
      ...data,
      timestamp: data.timestamp ? data.timestamp.toDate().toISOString() : null, // Convert Firestore Timestamp to ISO 8601 string
    });
  } catch (error) {
    console.error('Error fetching history entry by ID:', error);
    res.status(500).send({ message: 'Error fetching history entry', error: error.message });
  }
};

// Delete a history entry (ensure it belongs to the user)
exports.deleteHistoryEntry = async (req, res) => {
  try {
    const entryId = req.params.id;
    const userId = req.user.uid; // Get UID from authenticated user

    const entryRef = db.collection('history').doc(entryId);
    const entryDoc = await entryRef.get();

    if (!entryDoc.exists) {
      return res.status(404).send({ message: 'History entry not found.' });
    }

    // Ensure the entry belongs to the authenticated user before deleting
    if (entryDoc.data().user_id !== userId) {
      return res.status(403).send({ message: 'Unauthorized to delete this history entry.' });
    }

    await entryRef.delete();
    res.status(200).send({ message: 'History entry deleted successfully.' });
  } catch (error) {
    console.error('Error deleting history entry:', error);
    res.status(500).send({ message: 'Error deleting history entry', error: error.message });
  }
};
