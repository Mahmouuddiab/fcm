# Flutter Firebase Cloud Messaging (FCM)

A production-ready Flutter project demonstrating the implementation of **Firebase Cloud Messaging (FCM)** with support for Android and iOS.

## ✨ Features

* Firebase Cloud Messaging integration
* Push notifications in Foreground, Background, and Terminated states
* Local notifications using `flutter_local_notifications`
* Notification tap handling
* FCM token generation
* FCM token refresh listener
* APNs token support for iOS
* Topic subscription and unsubscription
* Delete FCM token
* Android notification channels
* iOS notification presentation options
* Background message handler
* Clean and reusable `FcmService`

---

## 📦 Packages

```yaml
firebase_core
firebase_messaging
flutter_local_notifications
```

---

## 📱 Supported Platforms

* ✅ Android
* ✅ iOS

---

## Project Structure

```
lib/
│
├── services/
│   └── fcm_service.dart
│
├── firebase_options.dart
│
└── main.dart
```

---

## Firebase Setup

### Android

1. Create a Firebase project.
2. Register your Android application.
3. Download `google-services.json`.
4. Place it inside:

```
android/app/
```

5. Enable Firebase Cloud Messaging.

---

### iOS

1. Register your iOS application.
2. Download `GoogleService-Info.plist`.
3. Add it to:

```
ios/Runner/
```

4. Enable Push Notifications.
5. Enable Background Modes → Remote Notifications.
6. Upload your APNs Authentication Key to Firebase.

---

## Android Manifest

Add the notification permission for Android 13+.

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

---

## Initialize Firebase

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  runApp(const MyApp());
}
```

---

## Initialize FCM Service

```dart
await FcmService.instance.init(
  onTap: (payload) {
    print(payload);
  },
  onMessage: (message) {
    print(message.notification?.title);
  },
);
```

---

## Get FCM Token

```dart
final token = await FcmService.instance.getToken();
print(token);
```

---

## Listen for Token Refresh

```dart
FcmService.instance.listenTokenRefresh((token) async {
  print(token);
});
```

---

## Subscribe to a Topic

```dart
await FcmService.instance.subscribeToTopic('news');
```

---

## Unsubscribe from a Topic

```dart
await FcmService.instance.unsubscribeFromTopic('news');
```

---

## Delete Token

```dart
await FcmService.instance.deleteToken();
```

---

## Show Local Notification

```dart
await FcmService.instance.showLocalNotification(message);
```

---

## Notification States

### Foreground

* Receives notification via `FirebaseMessaging.onMessage`
* Displays a local notification

### Background

* Handled using `firebaseMessagingBackgroundHandler`

### Terminated

* Open notification using

```dart
FirebaseMessaging.instance.getInitialMessage()
```

---

## iOS Support

* Notification permissions
* APNs token retrieval
* Foreground notification presentation
* Background notification support

---

## Android Support

* Notification channels
* High-priority notifications
* Local notification support
* Android 13+ notification permission

---

## Requirements

* Flutter 3.x or later
* Dart 3.x
* Firebase Project
* Android Studio or VS Code
* Xcode (for iOS)

---

## References

* Flutter
* Firebase Cloud Messaging
* Flutter Local Notifications

---

## License

This project is open-source and available for learning and production use.
