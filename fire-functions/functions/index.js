const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);

const db = admin.firestore();

// exports.testingUsersCollection = functions.pubsub
//   .schedule("*/5 * * * *")
//   //   .schedule("0 9 * * 4") // for every thursday
//   .onRun((context) => {
//     var docRef = db
//       .collection("users")
//       .doc("RoxEsgFFdLZu9un1i654DBIha4K3")
//       .get();
//     docRef.then(async (doc) => {
//       console.log(doc.data().username);
//       console.log("Sending notification to device!");
//       const deviceToken = doc.data().token;
//       const payload = {
//         notification: {
//           title: "Test notification from cloud",
//           body: "This is a test notification from cloud functions",
//           icon: "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/test%2FGDlogo.png?alt=media&token=46fc62df-e0e9-4822-ae58-5c7816949857",
//         },
//       };

//       const response = await admin
//         .messaging()
//         .sendToDevice(deviceToken, payload);

//       functions.logger.log(
//         "Notifications have been sent and tokens cleaned up."
//       );
//     });
//     return null;
//   });

exports.sendGuestUsersNotificationToRegister = functions.pubsub
  // .schedule("* * * * *")
  .schedule("0 9 * * 4") // for every thursday
  .onRun((context) => {
    var collectionRef = db.collection("guestUserTokens").get();
    collectionRef.then(async (snapshot) => {
      functions.logger.log("lenght of users == " + snapshot.docs.length);
      snapshot.docs.forEach(async (doc) => {
        db.collection("users")
          .where("token", "==", doc.data().token)
          .limit(1)
          .get()
          .then(async (value) => {
            if (value.docs.length == 0) {
              console.log(doc.data().token);
              console.log("Sending notification to device!");
              const deviceToken = doc.data().token;
              const payload = {
                notification: {
                  title: "👋 Hello!",
                  body: "We're giving away 20 Carats just for registering! These carats can be used to purchase premium content on us! Sign up and explore all the exciting features we have in store for you! ✨",
                  icon: "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/test%2FGDlogo.png?alt=media&token=46fc62df-e0e9-4822-ae58-5c7816949857",
                  click_action: "https://diamantrosegd.page.link/2q9Q",
                },
              };

              const response = await admin
                .messaging()
                .sendToDevice(deviceToken, payload);

              functions.logger.log(
                "Notifications have been sent and tokens cleaned up."
              );
            } else {
              functions.logger.log("USER ALREADY EXISTS!");
            }
          });
      });
    });
    return null;
  });
