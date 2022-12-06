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

exports.sendNotificationToUsersInterested = functions.https.onRequest(
  async (req, res) => {
    switch (req.method) {
      case "POST":
        const body = req.body;
        const genres = body["videoGenres"];
        const videoId = body["videoId"];

        // https://diamantrosegd.page.link/vJC3

        await db
          .collection("users")
          .get()
          .then(async (snapshot) => {
            snapshot.forEach(async (doc) => {
              if (doc.get("interested") != undefined) {
                console.log(doc.get("interested") + "EXISTS ANKE?");
                const userInterests = doc.data().interested;
                var arrayLength = userInterests.length;
                for (var i = 0; i < arrayLength; i++) {
                  var interests = userInterests[i];
                  console.log(interests);
                  if (genres.includes(interests)) {
                    console.log(doc.data().token);
                    console.log("Sending notification to device!");

                    const deviceToken = doc.data().token;
                    const payload = {
                      notification: {
                        title: `New ${interests} post for you!`,
                        body: "Theres a new post we believe would interest you!",
                        icon: "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/test%2FGDlogo.png?alt=media&token=46fc62df-e0e9-4822-ae58-5c7816949857",
                      },
                      data: {
                        videoId: `${videoId}`,
                      },
                    };

                    const response = await admin
                      .messaging()
                      .sendToDevice(deviceToken, payload);

                    functions.logger.log(
                      "Notifications have been sent and tokens cleaned up."
                    );
                  }
                }
              }
            });
          });

        res.status(200).send("ok");
        break;

      default:
        break;
    }
  }
);

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
                  title: "GD is waiting for you!",
                  body: "Sign up now and explore all the exciting features we have in store for you!✨",
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
