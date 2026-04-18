# Mobile Teaching Modules (Flutter)

Use this as your side-by-side mentor path while coding.

## Module A — App skeleton and state
1. What: `lib/src/app.dart` + `AppState`
2. Why: central state drives all screens and API calls.
3. Build task: add one new state field and expose it on UI.
4. Check: login/logout updates UI without restart.

## Module B — Auth and session persistence
1. What: `login/register` + `SharedPreferences` token restore.
2. Why: user remains signed in across app launches.
3. Build task: add "remember me" toggle.
4. Check: app boots directly to dashboard when token exists.

## Module C — Trusted circle flows
1. What: create circle and add member.
2. Why: safety notifications require a destination audience.
3. Build task: add member removal API wiring.
4. Check: circle member count updates after action.

## Module D — Trip safety lifecycle
1. What: start trip, location ping, mark arrived, end trip.
2. Why: this is the core safety journey.
3. Build task: add trip cancellation action.
4. Check: no location ping allowed after trip end.

## Module E — Device heartbeat and reliability
1. What: register device + periodic heartbeat.
2. Why: offline detection and reliability signal.
3. Build task: make heartbeat interval configurable.
4. Check: device `lastHeartbeatAt` updates in backend.

## Module F — SOS and alert acknowledgement
1. What: normal/silent SOS and acknowledge alert.
2. Why: emergency escalation and operator signal closure.
3. Build task: show only unacknowledged alerts in top list.
4. Check: ack action updates backend + UI instantly.

## Module G — Motion and 3D-like visual polish
1. What: animated safety hero custom painter.
2. Why: premium look without heavy rendering cost.
3. Build task: add second orbit ring with different speed.
4. Check: smooth animation >55 FPS on average devices.

## Module H — Play Store release
1. What: flavor build + `.aab` generation + internal testing.
2. Why: controlled rollout before production.
3. Build task: prepare release notes and tester group.
4. Check: internal testers install successfully from Play Console.
