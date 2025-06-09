// controllers/notificationController.js
const admin = require('firebase-admin');
const db = require('../config/firebase');

// ADMIN ONLY: Create a new notification
exports.createNotification = async (req, res) => {
  try {
    const { userId, title, message, type, data, timestamp } = req.body;
    // Assuming only authenticated admins can create notifications
    // You might add an isAdmin check here if needed: if (!req.user.isAdmin) return res.status(403)...

    if (!title || !message) {
      return res.status(400).send({ message: 'Title and message are required for notification.' });
    }

    let firestoreTimestamp = admin.firestore.FieldValue.serverTimestamp();
    if (timestamp && typeof timestamp === 'string') {
        // If a timestamp string is provided by frontend, parse it
        firestoreTimestamp = admin.firestore.Timestamp.fromDate(new Date(timestamp));
    }


    const newNotificationRef = await db.collection('notifications').add({
      user_id: userId || null, // Can be null for global notifications, or specific UID
      title,
      message,
      timestamp: firestoreTimestamp,
      is_read: false, // Notifications start as unread
      type: type || 'alert', // Default type
      data: data || {},
    });

    // Fetch the newly created document to get the server-set timestamp for the response
    const newNotificationDoc = await newNotificationRef.get();
    const notificationData = newNotificationDoc.data();

    res.status(201).send({
      id: newNotificationRef.id,
      user_id: notificationData.user_id,
      title: notificationData.title,
      message: notificationData.message,
      is_read: notificationData.is_read,
      type: notificationData.type,
      data: notificationData.data,
      timestamp: notificationData.timestamp ? notificationData.timestamp.toDate().toISOString() : null, // Convert to ISO 8601
    });
  } catch (error) {
    console.error('Error creating notification:', error);
    res.status(500).send({ message: 'Error creating notification', error: error.message });
  }
};

// Get all notifications for the authenticated user (and potentially global ones)
exports.getMyNotifications = async (req, res) => {
  try {
    const userId = req.user.uid; // Get UID from authenticated user

    const userNotificationsSnapshot = await db.collection('notifications')
      .where('user_id', '==', userId)
      .orderBy('timestamp', 'desc')
      .get();

    // Also fetch global notifications (where user_id is null)
    const globalNotificationsSnapshot = await db.collection('notifications')
      .where('user_id', '==', null)
      .orderBy('timestamp', 'desc')
      .get();

    let notifications = [];
    userNotificationsSnapshot.forEach(doc => {
      const data = doc.data();
      notifications.push({
        id: doc.id,
        ...data,
        timestamp: data.timestamp ? data.timestamp.toDate().toISOString() : null, // Convert to ISO 8601
      });
    });
    globalNotificationsSnapshot.forEach(doc => {
      const data = doc.data();
      notifications.push({
        id: doc.id,
        ...data,
        timestamp: data.timestamp ? data.timestamp.toDate().toISOString() : null, // Convert to ISO 8601
      });
    });

    // Sort combined list by timestamp again to ensure correct order
    notifications.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

    res.status(200).send(notifications);
  } catch (error) {
    console.error('Error fetching user notifications:', error);
    res.status(500).send({ message: 'Error fetching user notifications', error: error.message });
  }
};

// Mark a notification as read for the authenticated user
exports.markNotificationAsRead = async (req, res) => {
  try {
    const notificationId = req.params.id;
    const userId = req.user.uid;

    const notificationRef = db.collection('notifications').doc(notificationId);
    const notificationDoc = await notificationRef.get();

    if (!notificationDoc.exists) {
      return res.status(404).send({ message: 'Notification not found.' });
    }

    // Ensure the notification belongs to the user or is a global notification
    if (notificationDoc.data().user_id !== userId && notificationDoc.data().user_id !== null) {
      return res.status(403).send({ message: 'Unauthorized to modify this notification.' });
    }

    await notificationRef.update({
      is_read: true,
    });

    res.status(200).send({ message: 'Notification marked as read.' });
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).send({ message: 'Error marking notification as read', error: error.message });
  }
};

// Delete a notification for the authenticated user (or ADMIN)
exports.deleteNotification = async (req, res) => {
  try {
    const notificationId = req.params.id;
    const userId = req.user.uid;

    const notificationRef = db.collection('notifications').doc(notificationId);
    const notificationDoc = await notificationRef.get();

    if (!notificationDoc.exists) {
      return res.status(404).send({ message: 'Notification not found.' });
    }

    // Allow user to delete their own notifications, or admin to delete any (if you implement admin roles)
    if (notificationDoc.data().user_id !== userId && notificationDoc.data().user_id !== null /* && !req.user.isAdmin */) {
      return res.status(403).send({ message: 'Unauthorized to delete this notification.' });
    }

    await notificationRef.delete();
    res.status(200).send({ message: 'Notification deleted successfully.' });
  } catch (error) {
    console.error('Error deleting notification:', error);
    res.status(500).send({ message: 'Error deleting notification', error: error.message });
  }
};
