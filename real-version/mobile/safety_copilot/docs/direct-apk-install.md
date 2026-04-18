# Direct Android Install (No Play Store)

## Build Artifact
- APK: `releases/android/v1.0.0+1/safety-copilot-v1.0.0+1-prod-release.apk`
- SHA256: `83B1FEFE5344F23236647259458DA827D75193ABA4814C09B0890DE89083C9B7`

## Install On Your Phone
1. Copy APK to phone using USB, WhatsApp file, Drive, or any file transfer app.
2. On the phone, open APK from Files app.
3. If prompted, allow `Install unknown apps` for that file source.
4. Install and open Safety Copilot.

## Verify Integrity (Recommended)
Run on Windows:

```powershell
Get-FileHash "C:\Users\AKSHYA\OneDrive\Desktop\UJALA\animation\learning-safety-app\real-version\mobile\safety_copilot\releases\android\v1.0.0+1\safety-copilot-v1.0.0+1-prod-release.apk" -Algorithm SHA256
```

Expected hash:
`83B1FEFE5344F23236647259458DA827D75193ABA4814C09B0890DE89083C9B7`

## Fast USB Install (ADB)
```powershell
adb install -r "C:\Users\AKSHYA\OneDrive\Desktop\UJALA\animation\learning-safety-app\real-version\mobile\safety_copilot\releases\android\v1.0.0+1\safety-copilot-v1.0.0+1-prod-release.apk"
```

If signature mismatch occurs from old debug install:

```powershell
adb uninstall com.safetycopilot.safety_copilot
adb install "C:\Users\AKSHYA\OneDrive\Desktop\UJALA\animation\learning-safety-app\real-version\mobile\safety_copilot\releases\android\v1.0.0+1\safety-copilot-v1.0.0+1-prod-release.apk"
```

