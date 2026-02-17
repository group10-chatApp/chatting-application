// web/firebase-messaging-sw.js
importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-messaging-compat.js');

// Initialize Firebase - Copy config yako kutoka firebase_options.dart
firebase.initializeApp({
  apiKey: "AIzaSy...", // Weka API key yako
  authDomain: "...",
  projectId: "...",
  storageBucket: "...",
  messagingSenderId: "...", // Hii ni MUHIMU SANA!
  appId: "...",
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('Received background message: ', payload);

  const notificationTitle = payload.notification?.title || 'New Message';
  const notificationOptions = {
    body: payload.notification?.body || 'You have a new message',
    icon: '/favicon.ico'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});