// controllers/itemController.js - Contains the business logic for item operations

// Import the Firestore database instance
const db = require('../config/firebase'); // Path relative to this controller file
const admin = require('firebase-admin'); // Also need admin for FieldValue.serverTimestamp()

/**
 * Creates a new item in Firestore.
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
      createdAt: admin.firestore.FieldValue.serverTimestamp() // Add a server timestamp
    });

    // Respond with the ID of the newly created item
    res.status(201).send({ message: 'Item created successfully', id: newItemRef.id });
  } catch (error) {
    console.error('Error creating item:', error);
    res.status(500).send({ message: 'Error creating item', error: error.message });
  }
};

/**
 * Retrieves all items from Firestore.
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 */
exports.getAllItems = async (req, res) => {
  try {
    // Get all documents from the 'items' collection, ordered by creation time
    const snapshot = await db.collection('items').orderBy('createdAt', 'desc').get();
    const items = [];
    snapshot.forEach(doc => {
      // For each document, add its data and ID to the items array
      items.push({ id: doc.id, ...doc.data() });
    });
    res.status(200).send(items);
  } catch (error) {
    console.error('Error fetching items:', error);
    res.status(500).send({ message: 'Error fetching items', error: error.message });
  }
};

/**
 * Retrieves a single item by ID from Firestore.
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 */
exports.getItemById = async (req, res) => {
  try {
    const itemId = req.params.id; // Get the item ID from the URL parameters
    const itemDoc = await db.collection('items').doc(itemId).get(); // Get the document

    if (!itemDoc.exists) {
      // If the document doesn't exist, send a 404 response
      return res.status(404).send({ message: 'Item not found' });
    }

    // Respond with the item data and its ID
    res.status(200).send({ id: itemDoc.id, ...itemDoc.data() });
  } catch (error) {
    console.error('Error fetching item:', error);
    res.status(500).send({ message: 'Error fetching item', error: error.message });
  }
};

/**
 * Updates an existing item in Firestore.
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 */
exports.updateItem = async (req, res) => {
  try {
    const itemId = req.params.id; // Get the item ID from the URL parameters
    const updates = req.body; // Get the updates from the request body

    // Check if there are any updates provided
    if (Object.keys(updates).length === 0) {
      return res.status(400).send({ message: 'No update data provided' });
    }

    // Update the document in the 'items' collection
    await db.collection('items').doc(itemId).update(updates);
    res.status(200).send({ message: 'Item updated successfully' });
  } catch (error) {
    console.error('Error updating item:', error);
    res.status(500).send({ message: 'Error updating item', error: error.message });
  }
};

/**
 * Deletes an item from Firestore.
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 */
exports.deleteItem = async (req, res) => {
  try {
    const itemId = req.params.id; // Get the item ID from the URL parameters
    await db.collection('items').doc(itemId).delete(); // Delete the document
    res.status(200).send({ message: 'Item deleted successfully' });
  } catch (error) {
    console.error('Error deleting item:', error);
    res.status(500).send({ message: 'Error deleting item', error: error.message });
  }
};
