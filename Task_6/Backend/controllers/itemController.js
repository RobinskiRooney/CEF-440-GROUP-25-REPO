// controllers/itemController.js - Contains the business logic for item operations

const db = require('../config/firebase'); // Import Firestore database instance
const admin = require('firebase-admin'); // Needed for FieldValue.serverTimestamp()

/**
 * Creates a new item in Firestore. Requires authentication via verifyToken middleware.
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 */
exports.createItem = async (req, res) => {
  try {
    const { name, color, size } = req.body;

    // Basic validation
    if (!name || !color || !size) {
      return res.status(400).send({ message: 'Missing required fields: name, color, size' });
    }

    // Add a new document to the 'items' collection
    const newItemRef = await db.collection('items').add({
      name,
      color,
      size,
      createdAt: admin.firestore.FieldValue.serverTimestamp(), // Add a server timestamp
      createdBy: req.user.uid, // Add UID of the authenticated user
    });

    res.status(201).send({ message: 'Item created successfully', id: newItemRef.id });
  } catch (error) {
    console.error('Error creating item:', error);
    res.status(500).send({ message: 'Error creating item', error: error.message });
  }
};

/**
 * Retrieves all items from Firestore. Can be public or authenticated.
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 */
exports.getAllItems = async (req, res) => {
  try {
    const snapshot = await db.collection('items').orderBy('createdAt', 'desc').get();
    const items = [];
    snapshot.forEach(doc => {
      items.push({ id: doc.id, ...doc.data() });
    });
    res.status(200).send(items);
  } catch (error) {
    console.error('Error fetching items:', error);
    res.status(500).send({ message: 'Error fetching items', error: error.message });
  }
};

/**
 * Retrieves a single item by ID from Firestore. Can be public or authenticated.
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 */
exports.getItemById = async (req, res) => {
  try {
    const itemId = req.params.id;
    const itemDoc = await db.collection('items').doc(itemId).get();

    if (!itemDoc.exists) {
      return res.status(404).send({ message: 'Item not found' });
    }

    res.status(200).send({ id: itemDoc.id, ...itemDoc.data() });
  } catch (error) {
    console.error('Error fetching item:', error);
    res.status(500).send({ message: 'Error fetching item', error: error.message });
  }
};

/**
 * Updates an existing item in Firestore. Requires authentication via verifyToken middleware.
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 */
exports.updateItem = async (req, res) => {
  try {
    const itemId = req.params.id;
    const updates = req.body;

    if (Object.keys(updates).length === 0) {
      return res.status(400).send({ message: 'No update data provided' });
    }

    // Optional: Add a check if req.user.uid matches item's createdBy if enforcing ownership
    // const itemRef = db.collection('items').doc(itemId);
    // const itemSnapshot = await itemRef.get();
    // if (itemSnapshot.exists && itemSnapshot.data().createdBy !== req.user.uid) {
    //   return res.status(403).send({ message: 'Permission denied: Not your item.' });
    // }

    await db.collection('items').doc(itemId).update(updates);
    res.status(200).send({ message: 'Item updated successfully' });
  } catch (error) {
    console.error('Error updating item:', error);
    res.status(500).send({ message: 'Error updating item', error: error.message });
  }
};

/**
 * Deletes an item from Firestore. Requires authentication via verifyToken middleware.
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 */
exports.deleteItem = async (req, res) => {
  try {
    const itemId = req.params.id;

    // Optional: Add a check if req.user.uid matches item's createdBy if enforcing ownership
    // const itemRef = db.collection('items').doc(itemId);
    // const itemSnapshot = await itemRef.get();
    // if (itemSnapshot.exists && itemSnapshot.data().createdBy !== req.user.uid) {
    //   return res.status(403).send({ message: 'Permission denied: Not your item.' });
    // }

    await db.collection('items').doc(itemId).delete();
    res.status(200).send({ message: 'Item deleted successfully' });
  } catch (error) {
    console.error('Error deleting item:', error);
    res.status(500).send({ message: 'Error deleting item', error: error.message });
  }
};
