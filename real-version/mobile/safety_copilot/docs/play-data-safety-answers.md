# Google Play Data Safety - Pre-filled Answers (Safety Copilot)

Use this as your submission sheet while filling Play Console forms.

## A) Data Collection and Sharing
1. Does your app collect or share any of the required user data types?
- Answer: Yes

2. Is all user data collected by your app encrypted in transit?
- Answer: Yes (HTTPS API endpoints)

3. Do you provide a way for users to request that their data is deleted?
- Current status: Manual request via support email
- Recommended Play answer: Yes (if you include deletion request instructions in policy/support)
- Production recommendation: add in-app self-delete endpoint and UI before full public rollout

## B) Data Shared
- Data shared with third parties: No (for this build's declared behavior)

## C) Data Collected (declare these)

### 1. Personal info
- Name: Collected
  - Purpose: App functionality, account management
  - Processing: Required for account setup
- Phone number: Collected
  - Purpose: App functionality, account management, trusted circle linking
  - Processing: Required for account setup

### 2. Location
- Precise location: Collected
  - Purpose: App functionality (live trip monitoring), safety alerts
  - Processing: Required for core safety/trip features

### 3. App activity / User generated content
- In-app messages or notes (SOS note): Collected (if provided)
  - Purpose: App functionality (SOS context)
  - Processing: Optional

### 4. Device or other IDs
- Device identifier and push token: Collected
  - Purpose: App functionality, notifications, fraud prevention, reliability
  - Processing: Required for reliable device session behavior

### 5. Diagnostics (optional declaration)
- If not actively collecting crash/analytics SDK data: mark Not collected

## D) Security Practices
- Encryption in transit: Yes
- Account creation: Yes
- Independent security review: No (unless you have one)

## E) Permissions Justification Text (copy for Play)

### Background location
Safety Copilot uses background location to continue live safety monitoring during active trips, even when the app is minimized or the screen is off. This supports arrival detection, route-risk checks, and emergency workflows for trusted circle safety.

### Foreground precise location
Safety Copilot requires precise location to provide real-time trip tracking, destination ETA context, and emergency SOS metadata.

### Notifications
Safety Copilot uses notifications for critical safety events including SOS, silent SOS, low battery, offline risk, and arrival updates.

## Final Review Notes
- Ensure policy URL is live and exactly matches declared behavior.
- Keep declarations aligned with what the app actually does in code.
- If you add Firebase Messaging, re-check whether additional data types must be declared.
