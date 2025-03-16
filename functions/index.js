//const functions = require("firebase-functions");
//const admin = require("firebase-admin");
//
//admin.initializeApp();
//
//exports.sendNewMessageNotification = functions.database
//    .ref("/chats/{chatId}/messages/{messageId}")
//    .onCreate(async (snapshot, context) => {
//      const messageData = snapshot.val();
//      const chatId = context.params.chatId;
//      const senderId = messageData.senderId;
//      const recipientId = messageData.receiverId;
//
//      try {
//      // Fetch recipient's FCM token from Firestore
//        const userDoc = await admin.firestore()
//            .collection("users")
//            .doc(recipientId)
//            .get();
//        const fcmToken = userDoc.exists ?
//        userDoc.data().fcmToken :
//        null;
//
//        if (!fcmToken) {
//          console.log(
//              `No FCM token found for recipient: ${recipientId}`,
//          );
//          return null;
//        }
//
//        // Fetch sender's name from Firestore
//        const senderDoc = await admin.firestore()
//            .collection("users")
//            .doc(senderId)
//            .get();
//        const senderName = senderDoc.exists ?
//        senderDoc.data().fullName :
//        "Someone";
//
//        // Prepare notification payload
//        const payload = {
//          notification: {
//            title: `New message from ${senderName}`,
//            body: messageData.message,
//          },
//          data: {
//            chatId,
//            senderId,
//            recipientId,
//          },
//        };
//
//        // Send notification to recipient
//        await admin.messaging().sendToDevice(fcmToken, payload);
//        console.log(
//            `Notification sent successfully to ${recipientId}`,
//        );
//        return null;
//      } catch (error) {
//        console.error(
//            `Error sending notification for chat ${chatId}:`,
//            error,
//        );
//        return null;
//      }
//    });
