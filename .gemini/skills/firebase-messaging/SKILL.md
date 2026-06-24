---
name: firebase-messaging
description: "Client-side Firebase Cloud Messaging (FCM) setup and handling in Flutter. Use when handling push notification permissions, FCM tokens, foreground/background/terminated message handling, or notification tap routing. Note: in this project, FCM messages are sent server-side via Supabase Edge Functions — do not implement server-side FCM dispatch in Flutter."
---

# Firebase Cloud Messaging (Client-Side) Skill

This skill covers client-side FCM integration in Flutter.

## Project Architecture Note

In this project, FCM push notifications are **sent server-side** via Supabase Edge Functions using the HTTP v1 API with a Service Account. The client is only responsible for:

1. Requesting permissions
2. Retrieving and storing the FCM token in `profiles.fcm_token`
3. Handling incoming foreground/background/terminated messages
4. Routing notification taps to the correct screen

See `docs/ai/supabase.md` for the full server-side notification architecture (edge functions, notification_queue table, trigger chain).

---

## 1. Setup

```
flutter pub add firebase_messaging
```

**iOS:**
- Enable **Push Notifications** and **Background Modes** in Xcode.
- Upload your **APNs authentication key** to Firebase.
- Do not disable method swizzling — required for FCM token handling.

**Android:**
- Devices must run Android 4.4+ with Google Play services.
- Set a default notification channel in `AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="high_importance_channel" />
```

---

## 2. Permissions

```dart
NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);
```

- **iOS / macOS / Android 13+:** request permission before receiving payloads.
- **Android < 13:** `authorizationStatus` returns `authorized` unless the user has disabled notifications in OS settings.

---

## 3. Token Management

**Get FCM token and save to the backend:**

```dart
final fcmToken = await FirebaseMessaging.instance.getToken();
// save fcmToken to profiles.fcm_token via the auth datasource
```

**Listen for token refresh:**

```dart
FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
  // update profiles.fcm_token
});
```

**Apple platforms — ensure APNs token before FCM:**

```dart
final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
if (apnsToken != null) {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  // save token
}
```

**Token lifecycle:**
- Save the token when the user signs in.
- Remove or clear the token when the user signs out to prevent cross-user notifications.

---

## 4. Message Handling

**Foreground messages:**

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Show an in-app notification or update state
  if (message.notification != null) {
    // display local UI notification
  }
});
```

**Background messages (top-level function required):**

```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // process message silently — do not update UI here
}

void main() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}
```

Background handler rules:
- Must be a **top-level function** (not anonymous, not a class method).
- Annotate with `@pragma('vm:entry-point')` to prevent tree-shaking in release builds.
- Cannot update app UI state — runs in a separate isolate.
- Call `Firebase.initializeApp()` before using any Firebase service.

**iOS foreground notification display:**

```dart
await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  alert: true,
  badge: true,
  sound: true,
);
```

**Android foreground:** notification messages arriving while the app is in the foreground don't display a visible notification by default. Consume the payload via `onMessage` and show your own in-app UI.

---

## 5. Notification Tap Handling

Always handle both scenarios:

**App was terminated:**

```dart
RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
if (initialMessage != null) {
  // route to the correct screen based on message.data
}
```

**App was in background:**

```dart
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // route to the correct screen based on message.data
});
```

---

## 6. Platform-Specific Behavior

- **iOS:** If the user swipes the app away from the app switcher, the app must be manually reopened for background messages to resume.
- **Android:** Force-quitting from device settings prevents background messages until the user reopens the app.
- **Android foreground:** Use a local notifications plugin (e.g., `flutter_local_notifications`) to display a visible notification while the app is in the foreground.

---

## Common Pitfalls

| Pitfall | Fix |
|---|---|
| Not clearing FCM token on sign-out | Clear `profiles.fcm_token` when the user signs out |
| Background handler is a class method | Must be a top-level function annotated with `@pragma('vm:entry-point')` |
| Missing `Firebase.initializeApp()` in background handler | Always call it before other Firebase services |
| Only handling background tap but not terminated tap | Always handle both `getInitialMessage` and `onMessageOpenedApp` |
| Assuming FCM can send messages directly from the Flutter app | Sending is server-side only (Supabase Edge Functions in this project) |
