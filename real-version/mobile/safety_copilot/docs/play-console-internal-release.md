# Play Console Internal Testing - Safety Copilot

## Build Artifact (ready)
- AAB: `build/app/outputs/bundle/prodRelease/app-prod-release.aab`
- SHA256: `FE936C588C32B61E037224FE7F57E7BC525A7BBB8082E71B0565EAC0C862649D`

## Signing Assets (do not lose)
- Keystore: `android/upload-keystore.jks`
- Config: `android/key.properties`

Backup both files in safe storage before first Play upload.

## 1) Create Play App
1. Open Google Play Console.
2. Create app: `Safety Copilot`.
3. Default language: English.
4. App type: App.
5. Free/Paid: Free.

## 2) App Content Setup (required)
1. Privacy policy URL (must be public HTTPS URL).
2. Data safety form.
3. Target audience.
4. Ads declaration.
5. App access declaration (if login is required, provide test credentials).
6. Content rating questionnaire.

## 3) Store Listing
1. App name, short description, full description.
2. Screenshots (phone required).
3. App icon (512x512 PNG).
4. Feature graphic (1024x500 PNG).

## 4) Internal Testing Upload
1. Go to: Testing -> Internal testing.
2. Create release.
3. Upload `app-prod-release.aab`.
4. Add release notes.
5. Save and review.
6. Roll out to internal testing.

## 5) Add Testers
1. Add tester emails or Google Group in Internal testing.
2. Copy opt-in link from Play Console.
3. Testers accept invite and install via Play Store.

## 6) Validation Checklist
- App installs from Play internal track.
- Login works.
- Trip start/live tracking/arrival notification works.
- SOS works.
- Alerts feed and acknowledgement works.
- No startup crash on Android 13/14/15 devices.

## Rebuild Command
From `android` directory:

```powershell
$env:JAVA_HOME='C:\Program Files\Java\jdk-18.0.2.1'
$env:GRADLE_USER_HOME='C:\Users\AKSHYA\.codex-gradle-home'
.\gradlew.bat bundleProdRelease --no-daemon
```
