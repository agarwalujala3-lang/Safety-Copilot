# Private Tester Distribution (Without Play Store)

## Package Ready
- APK: `releases/android/v1.0.0+1/safety-copilot-v1.0.0+1-prod-release.apk`
- SHA256: `83B1FEFE5344F23236647259458DA827D75193ABA4814C09B0890DE89083C9B7`

## Option A (Recommended): Firebase App Distribution
Best private workflow with tester groups and release history.

### One-time setup
1. Create a Firebase project.
2. Add Android app with package id: `com.safetycopilot.safety_copilot`.
3. Install Firebase CLI:
```powershell
npm install -g firebase-tools
firebase login
```
4. Create tester group (example: `internal-testers`).

### Distribute with prepared script
Run:
```powershell
.\scripts\distribution\firebase-distribute.ps1 -FirebaseAppId "<firebase-android-app-id>" -Groups "internal-testers" -ReleaseNotes "Safety Copilot v1.0.0 internal build"
```

## Option B: Private Drive Link (Fastest)
1. Upload APK to private Google Drive or OneDrive folder.
2. Share access only to tester email IDs.
3. Send testers both:
- Download link
- `SHA256SUM.txt` for integrity check

## Option C: Local Team Testing (Same Wi-Fi)
From APK directory:
```powershell
cd "C:\Users\AKSHYA\OneDrive\Desktop\UJALA\animation\learning-safety-app\real-version\mobile\safety_copilot\releases\android\v1.0.0+1"
python -m http.server 8090
```
Then testers on same Wi-Fi open:
`http://<your-laptop-ip>:8090/safety-copilot-v1.0.0+1-prod-release.apk`

## Tester Message Template
Hello tester, install the Safety Copilot internal APK from the provided link.
After install, test:
1. Register/Login
2. Create circle + add member
3. Start trip + live updates
4. Trigger SOS/Silent SOS
5. Mark arrival/end trip
6. Acknowledge alerts

Please report crashes, screen name, and exact steps to reproduce.

