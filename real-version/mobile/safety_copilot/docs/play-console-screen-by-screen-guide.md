# Play Console Internal Testing - Screen-by-Screen Guide

Follow in this exact order.

## 1) Create App
1. Open Play Console -> All apps -> Create app
2. App name: Safety Copilot
3. Default language: English (United States)
4. App type: App
5. Free/Paid: Free
6. Confirm declarations and create

## 2) Setup Dashboard Tasks
Complete the required cards one by one:
1. App access
2. Ads
3. Content rating
4. Target audience and content
5. Data safety
6. Privacy policy

## 3) App Access
1. If login is required, choose "All or some functionality is restricted"
2. Provide test account:
- Phone: (your test phone)
- Password: (your test password)
3. Add any special steps reviewer needs

## 4) Ads
1. Choose "No" if app has no ads SDK/in-app ads

## 5) Content Rating
1. Start questionnaire
2. Category: Safety / Utility / Lifestyle
3. Answer honestly
4. Submit and apply assigned rating

## 6) Target Audience
1. Select primary age group(s)
2. If not directed to children, choose accordingly
3. Complete policy confirmations

## 7) Data Safety
1. Open Data Safety form
2. Use answers from `play-data-safety-answers.md`
3. Save each section and submit

## 8) Privacy Policy
1. Use this privacy policy URL: https://safety-copilot-ui-119944160349-20260410111252.s3.ap-south-1.amazonaws.com/privacy-policy.html
2. Paste URL in Privacy Policy field
3. Save

## 9) Main Store Listing
1. Go to Grow -> Store presence -> Main store listing
2. Paste text from `play-store-listing-copy.md`
3. Upload required graphics:
- App icon: 512x512 PNG
- Feature graphic: 1024x500 PNG
- Phone screenshots (minimum required)
4. Save draft

## 10) Create Internal Test Release
1. Go to Test and release -> Testing -> Internal testing
2. Create new release
3. Upload AAB:
- `build/app/outputs/bundle/prodRelease/app-prod-release.aab`
4. Add release notes from `play-store-release-notes.md`
5. Review and roll out to internal testing

## 11) Add Testers
1. Internal testing -> Testers
2. Add tester emails or Google Group
3. Save and copy opt-in link
4. Testers accept invite and install from Play Store

## 12) Post-Upload Validation
1. Install app from internal track on at least 2 devices
2. Validate login, trip start, live updates, arrival, SOS, alerts ack
3. Confirm no crash on first-run path

## 13) Before Production (Important)
1. Implement user self-service account deletion in app/backend
2. Replace placeholder push token flow with production FCM integration
3. Re-check Data Safety declarations after any SDK change

