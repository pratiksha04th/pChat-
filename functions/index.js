exports.onNewMessage = functions.database
  .ref('/messages/{chatId}/{msgId}')
  .onCreate(async (snapshot, context) => {

    const msg = snapshot.val();
    if (!msg) return null;

    const receiverId = msg.receiverId;

    const tokenSnap = await admin.database()
      .ref(`users/${receiverId}/fcmToken`)
      .get();

    const token = tokenSnap.val();
    if (!token) return null;

    const payload = {
      data: {
        type: 'chat',
        conversationTitle: msg.senderName,
        sender: msg.senderName,
        message: msg.text,
      },
    };

    return admin.messaging().sendToDevice(token, payload);
  });
