// controllers/faqController.js
const admin = require('firebase-admin');
const db = require('../config/firebase');

// Get all FAQs (publicly accessible)
exports.getAllFAQs = async (req, res) => {
  try {
    // FAQs are generally public, no user_id filter needed
    const snapshot = await db.collection('faqs').orderBy('order', 'asc').orderBy('question', 'asc').get();
    const faqs = [];
    snapshot.forEach(doc => {
      const data = doc.data();
      faqs.push({
        id: doc.id,
        ...data,
        created_at: data.created_at ? data.created_at.toDate().toISOString() : null,
        updated_at: data.updated_at ? data.updated_at.toDate().toISOString() : null,
      });
    });
    res.status(200).send(faqs);
  } catch (error) {
    console.error('Error fetching FAQs:', error);
    res.status(500).send({ message: 'Error fetching FAQs', error: error.message });
  }
};

// ADMIN ONLY: Create a new FAQ item
exports.createFAQ = async (req, res) => {
  try {
    const { question, answer, category, order } = req.body;
    // You might add an admin role check here: if (!req.user.isAdmin) return res.status(403)...

    if (!question || !answer) {
      return res.status(400).send({ message: 'Question and answer are required for FAQ.' });
    }

    const newFAQRef = await db.collection('faqs').add({
      question,
      answer,
      category: category || 'General',
      order: order || 999, // Default order
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Fetch the newly created document to get the server-set timestamps for the response
    const newFAQDoc = await newFAQRef.get();
    const faqData = newFAQDoc.data();

    res.status(201).send({
      id: newFAQRef.id,
      question: faqData.question,
      answer: faqData.answer,
      category: faqData.category,
      order: faqData.order,
      created_at: faqData.created_at ? faqData.created_at.toDate().toISOString() : null,
      updated_at: faqData.updated_at ? faqData.updated_at.toDate().toISOString() : null,
    });
  } catch (error) {
    console.error('Error creating FAQ:', error);
    res.status(500).send({ message: 'Error creating FAQ', error: error.message });
  }
};

// ADMIN ONLY: Update an FAQ item
exports.updateFAQ = async (req, res) => {
  try {
    const faqId = req.params.id;
    const updates = req.body;
    // You might add an admin role check here

    const faqRef = db.collection('faqs').doc(faqId);
    const faqDoc = await faqRef.get();

    if (!faqDoc.exists) {
      return res.status(404).send({ message: 'FAQ not found.' });
    }

    await faqRef.update({
      ...updates,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Fetch the updated document to send back the latest data
    const updatedFAQDoc = await faqRef.get();
    const updatedFAQData = updatedFAQDoc.data();

    res.status(200).send({
      id: updatedFAQDoc.id,
      ...updatedFAQData,
      created_at: updatedFAQData.created_at ? updatedFAQData.created_at.toDate().toISOString() : null,
      updated_at: updatedFAQData.updated_at ? updatedFAQData.updated_at.toDate().toISOString() : null,
    });
  } catch (error) {
    console.error('Error updating FAQ:', error);
    res.status(500).send({ message: 'Error updating FAQ', error: error.message });
  }
};

// ADMIN ONLY: Delete an FAQ item
exports.deleteFAQ = async (req, res) => {
  try {
    const faqId = req.params.id;
    // You might add an admin role check here

    const faqRef = db.collection('faqs').doc(faqId);
    const faqDoc = await faqRef.get();

    if (!faqDoc.exists) {
      return res.status(404).send({ message: 'FAQ not found.' });
    }

    await faqRef.delete();
    res.status(200).send({ message: 'FAQ deleted successfully.' });
  } catch (error) {
    console.error('Error deleting FAQ:', error);
    res.status(500).send({ message: 'Error deleting FAQ', error: error.message });
  }
};
