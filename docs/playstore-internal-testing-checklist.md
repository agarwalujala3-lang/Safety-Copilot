# Play Store Internal Testing Checklist

## 1. Account and app setup
1. Create Google Play Console account.
2. Create app entry: `Safety Copilot`.
3. Set default language and app category.

## 2. Store listing assets
1. App icon (512x512).
2. Feature graphic (1024x500).
3. Phone screenshots (minimum 2).
4. Short description and full description.

## 3. Policy assets
1. Privacy policy URL.
2. Data safety form:
   - Location (precise/background)
   - Device/app identifiers
   - Crash logs/diagnostics
3. Permission declarations:
   - Location foreground/background
   - Notifications
4. Emergency/safety disclaimer in app and listing.

## 4. Internal test track release
1. Upload Android App Bundle (`.aab`).
2. Create Internal testing release.
3. Add tester emails/group.
4. Roll out release to internal testers.

## 5. Validation before production
1. End-to-end trip flow works on real devices.
2. Alerts and SOS trigger reliably in background.
3. No blocker crashes in Play pre-launch report.
