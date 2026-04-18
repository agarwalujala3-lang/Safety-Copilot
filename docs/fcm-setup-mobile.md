# FCM Setup for Safety Copilot Mobile

Current mobile code registers a placeholder push token so backend flow works.
For production push notifications, complete these steps:

1. Create Firebase project and Android app entry.
2. Download `google-services.json` and place it in:
   `mobile/safety_copilot/android/app/google-services.json`
3. Add dependencies:
   - `firebase_core`
   - `firebase_messaging`
4. Initialize Firebase in `main.dart` before app bootstrap.
5. Request notification permission and fetch FCM token.
6. Send real FCM token via `/devices/register`.
7. Handle foreground/background/terminated notification taps.

Test checklist:
1. Device receives alert push on active trip events.
2. Tapping notification opens app and lands on dashboard.
3. Token refresh updates backend automatically.
