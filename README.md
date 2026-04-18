# Learning Safety App

This workspace now contains the full real MVP build with:

1. Full backend safety engine (auth, circles, trips, live location, alerts, SOS)
2. Animated frontend dashboard with 3D visuals
3. Android-first Flutter mobile app scaffold with Play Store flavor setup
4. Structured module-by-module teaching docs

## Folder map

- `docs/full-modules-guide.md`: complete teaching flow from foundation to real app
- `docs/aws-ai-architecture.md`: cloud + AI extension strategy
- `docs/mobile-teaching-modules.md`: step-by-step Flutter learning path
- `real-version/backend`: API backend (Node + Express + JSON store)
- `real-version/frontend`: animated React + 3D UI
- `real-version/mobile/safety_copilot`: Flutter Android app

## Run locally

### 1) Backend

```bash
cd real-version/backend
npm install
npm run start
```

Runs on `http://localhost:4002`

### 2) Frontend

```bash
cd real-version/frontend
npm install
npm run dev
```

Runs on `http://localhost:5173`

### 3) Flutter mobile

```bash
cd real-version/mobile/safety_copilot
flutter pub get
flutter run --flavor dev --dart-define=FLAVOR=dev --dart-define=API_BASE_URL=https://yegajpcluzigy6ffamfvwopxry0ejyao.lambda-url.ap-south-1.on.aws/api/v1
```
