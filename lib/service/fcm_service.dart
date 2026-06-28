import 'dart:convert'; // Required for encoding/decoding local notification payload maps
import 'package:fcm/main.dart';
import 'package:fcm/screen/booking_detail_screen.dart';
import 'package:fcm/screen/chat-screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _isInitialized = false;

  // Callback for chat message notifications
  Function(String)? _onChatMessageReceived;

  // Callback for refreshing conversations list
  Function()? _onConversationsRefresh;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  // Set callback for chat message notifications
  void setChatMessageCallback(Function(String) callback) {
    print('📱 Setting chat message callback');
    _onChatMessageReceived = callback;
  }

  // Set callback for refreshing conversations
  void setConversationsRefreshCallback(Function() callback) {
    print('📱 Setting conversations refresh callback');
    _onConversationsRefresh = callback;
  }

  // Remove callback
  void removeChatMessageCallback() {
    print('📱 Removing chat message callback');
    _onChatMessageReceived = null;
  }

  // Remove conversations refresh callback
  void removeConversationsRefreshCallback() {
    print('📱 Removing conversations refresh callback');
    _onConversationsRefresh = null;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Request permission for iOS
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('User granted permission: ${settings.authorizationStatus}');

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      print('FCM Token: $_fcmToken');

      // Save token to SharedPreferences
      if (_fcmToken != null) {
        await _saveFcmToken(_fcmToken!);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _saveFcmToken(newToken);
        print('FCM Token refreshed: $newToken');
      });

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background/minimized
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a dead/terminated state via notification
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        // A minor 500ms delay ensures MaterialApp is completely drawn and navigatorKey is fully active
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationTap(initialMessage);
        });
      }

      _isInitialized = true;
      print('Firebase Messaging Service initialized successfully');
    } catch (e) {
      print('Error initializing Firebase Messaging Service: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'tall3at_channel',
      'Tall3at Notifications',
      description: 'Channel for Tall3at notifications',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  Future<void> _saveFcmToken(String token) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  Future<String?> getFcmToken() async {
    if (_fcmToken != null) return _fcmToken;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _fcmToken = prefs.getString('fcm_token');
      return _fcmToken;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('🔥 Got a message whilst in the foreground!');
    print('🔥 Message data: ${message.data}');

    // Refresh conversations list for any notification
    if (_onConversationsRefresh != null) {
      print('🔥 Notification received, refreshing conversations list');
      _onConversationsRefresh!();
    } else {
      print('🔥 Conversations refresh callback is null');
    }

    // Refresh messages for any notification
    if (_onChatMessageReceived != null) {
      print('🔥 Notification received, refreshing messages');
      _onChatMessageReceived!('any'); // Pass 'any' to indicate any notification
    } else {
      print('🔥 Chat message callback is null');
    }

    if (message.notification != null) {
      print('🔥 Message also contained a notification: ${message.notification}');
      showLocalNotification(message);
    }
  }

  // Triggers when a Firebase Background Push Notification is clicked
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped (FCM Stream): ${message.data}');
    _handleNotificationNavigation(message.data);
  }

  // Triggers when a Local Foreground Notification banner is clicked
  void _onNotificationTap(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        // Decode the JSON string payload back into a strongly typed Map
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        _handleNotificationNavigation(data);
      } catch (e) {
        print('Error parsing local notification payload: $e');
      }
    }
  }

  // Core navigation gateway logic
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    print('Handling notification navigation with data: $data');

    // Safety check to verify that your data map contains the routing instruction
    if (data.containsKey('screen')) {
      final String screen = data['screen'];

      // Route destination pattern 1: Booking System
      if (screen == 'booking') {
        final String? bookingId = data['bookingId']?.toString();

        // Target screen navigation using the imported global navigatorKey
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => BookingDetailScreen(bookingId: bookingId),
          ),
        );
      }

      // Route destination pattern 2: Messaging System
      if (screen == 'chat') {
        final String? chatId = data['chatId']?.toString();

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(chatId: chatId),
          ),
        );
      }
    }
  }

  Future<void> showBookingNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Create a fallback RemoteMessage layout
    RemoteMessage message = RemoteMessage(
      notification: RemoteNotification(title: title, body: body),
      data: data ?? {},
    );

    // Pass down to standard localized workflow
    await showLocalNotification(message);
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'tall3at_channel',
      'Tall3at Notifications',
      channelDescription: 'Channel for Tall3at app notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Convert the data Map to a JSON string so it transfers perfectly across platform lines
    final String stringPayload = jsonEncode(message.data);

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'Tall3at',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: stringPayload,
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
      print('FCM token deleted');
    } catch (e) {
      print('Error deleting FCM token: $e');
    }
  }
}

// Background message handler top level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}