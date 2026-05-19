importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyByJRiuHB7LJo6MvvRBVSjWjw7H9gqB9vw",
  authDomain: "apnademand-cb47f.firebaseapp.com",
  projectId: "apnademand-cb47f",
  storageBucket: "apnademand-cb47f.firebasestorage.app",
  messagingSenderId: "351307071676",
  appId: "1:351307071676:web:fae3817d9d3c8aed1390b9",
  measurementId: "G-DLQMC0RNS6"
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});