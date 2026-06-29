import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../main.dart'; // Make sure this path correctly points to your main.dart

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await Future.wait([
      requestPermission(),
      getToken(),
    ]);

    /// 1. App in Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Trigger the local notification banner for foreground execution
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id, // Uses the 'high_importance_channel' from main.dart
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: message.data.toString(),
        );
      }
    });

    /// 2. App in Background (User taps notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });

    /// 3. App Terminated (Launched via notification tap)
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationClick(initialMessage);
      });
    }
  }

  void _handleNotificationClick(RemoteMessage message) {
    final Map<String, dynamic> data = message.data;

    // Example routing logic: Adjust this to your app's deep-linking requirements
    if (data.containsKey('screen')) {
      final String screen = data['screen'];
      if (screen == 'booking' && data.containsKey('bookingId')) {
        final String bookingId = data['bookingId'];

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Booking Details')),
              body: Center(child: Text('Booking ID: $bookingId')),
            ),
          ),
        );
      }
    }
  }

  Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('Authorization Status: ${settings.authorizationStatus}');
  }

  Future<String?> getToken() async {
    final token = await _messaging.getToken();
    print('FCM Token: $token');
    _messaging.onTokenRefresh.listen((newToken) {
      print('New FCM Token: $newToken');
    });
    return token;
  }
}