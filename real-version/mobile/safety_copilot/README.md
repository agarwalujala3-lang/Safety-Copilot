# Safety Copilot Mobile (Flutter)

Android-first Flutter app wired to the Safety Copilot backend.

## Features implemented

1. Auth flow (register/login/logout)
2. Trusted circle creation and member add
3. Trip start, live location ping, arrival and end actions
4. SOS and silent SOS triggers
5. Alerts feed with acknowledgement action
6. Device registration + periodic heartbeat
7. Animated "3D-like" safety hero UI

## Environment and flavors

### Dev flavor
```bash
flutter run --flavor dev --dart-define=FLAVOR=dev --dart-define=API_BASE_URL=https://6rpyxxaw7c.execute-api.ap-south-1.amazonaws.com/api/v1 --dart-define=API_FALLBACK_URLS=https://yegajpcluzigy6ffamfvwopxry0ejyao.lambda-url.ap-south-1.on.aws/api/v1
```

### Prod flavor
```bash
flutter run --flavor prod --dart-define=FLAVOR=prod --dart-define=API_BASE_URL=https://6rpyxxaw7c.execute-api.ap-south-1.amazonaws.com/api/v1 --dart-define=API_FALLBACK_URLS=https://yegajpcluzigy6ffamfvwopxry0ejyao.lambda-url.ap-south-1.on.aws/api/v1
```

## Build Android App Bundle for Play Store

```bash
flutter build appbundle --flavor prod --dart-define=FLAVOR=prod --dart-define=API_BASE_URL=https://6rpyxxaw7c.execute-api.ap-south-1.amazonaws.com/api/v1 --dart-define=API_FALLBACK_URLS=https://yegajpcluzigy6ffamfvwopxry0ejyao.lambda-url.ap-south-1.on.aws/api/v1
```

Output:
`build/app/outputs/bundle/prodRelease/app-prod-release.aab`

## Notes for production rollout

1. Replace placeholder FCM token flow with Firebase Messaging integration.
2. Configure release signing in `android/app/build.gradle.kts`.
3. Validate background location behavior on physical Android devices.
4. Complete Play Console data safety and privacy policy forms.
