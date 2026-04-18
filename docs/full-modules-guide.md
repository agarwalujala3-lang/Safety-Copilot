# Full Modules Guide (Build + Learn)

This guide teaches the exact app in this repo module by module.

## Module 1: Foundations and architecture

What you learn:
1. Client/server flow
2. API contract basics
3. Data entities for safety domain

Where in code:
1. `real-version/backend/src/app.js`
2. `real-version/backend/src/routes/index.js`

Practice:
1. Explain request path from frontend to backend for `POST /trips/start`
2. Draw DB entities: users, circles, trips, alerts

## Module 2: Authentication

What you learn:
1. Password hashing with `scrypt`
2. Token issuing and verification
3. Route protection with middleware

Where in code:
1. `real-version/backend/src/services/passwordService.js`
2. `real-version/backend/src/services/tokenService.js`
3. `real-version/backend/src/middleware/authenticate.js`
4. `real-version/backend/src/controllers/authController.js`

Practice:
1. Rebuild login flow manually from memory
2. Add one custom validation rule in register

## Module 3: Trusted circles

What you learn:
1. Owner/member roles
2. Membership checks for access control
3. Pending invitations via phone

Where in code:
1. `real-version/backend/src/services/circleService.js`
2. `real-version/backend/src/controllers/circleController.js`
3. `real-version/backend/src/routes/circleRoutes.js`

Practice:
1. Add a `remove member` endpoint
2. Restrict it to circle owner

## Module 4: Trip lifecycle

What you learn:
1. Start/active/end trip state machine
2. Owner-only trip actions
3. Active-trip guard

Where in code:
1. `real-version/backend/src/services/tripService.js` (`startTrip`, `endTrip`)
2. `real-version/backend/src/controllers/tripController.js`
3. `real-version/backend/src/routes/tripRoutes.js`

Practice:
1. Add `cancel trip` status
2. Prevent location pings for cancelled trips

## Module 5: Live location and safety rule engine

What you learn:
1. Location ingestion design
2. Haversine distance and polyline deviation
3. Rule thresholds and alert throttling

Where in code:
1. `real-version/backend/src/services/geoService.js`
2. `real-version/backend/src/services/tripService.js` (`ingestLocation`)

Practice:
1. Change deviation threshold and verify alert behavior
2. Add one new rule: no movement for N minutes

## Module 6: Emergency workflows and alerts

What you learn:
1. SOS and silent SOS
2. Offline heartbeat checks
3. Alert visibility by circle membership

Where in code:
1. `real-version/backend/src/services/tripService.js` (`triggerSOS`, `runOfflineChecks`, `listAlertsForUser`)
2. `real-version/backend/src/controllers/alertController.js`
3. `real-version/backend/src/routes/alertRoutes.js`

Practice:
1. Add alert acknowledgement endpoint
2. Track acknowledged timestamp

## Module 7: Frontend app integration

What you learn:
1. Token session handling
2. Calling protected APIs
3. Dashboard state refresh strategy

Where in code:
1. `real-version/frontend/src/services/api.js`
2. `real-version/frontend/src/App.jsx`

Practice:
1. Add a small “active trip timer” UI
2. Add validation for destination fields before `startTrip`

## Module 8: 3D visuals and motion polish

What you learn:
1. Three.js scene in React
2. Motion choreography with Framer Motion
3. Responsive animated layout design

Where in code:
1. `real-version/frontend/src/components/SafetyOrb3D.jsx`
2. `real-version/frontend/src/styles/app.css`
3. `real-version/frontend/src/App.jsx` (animated cards)

Practice:
1. Change the 3D object to a cube shield
2. Add one additional motion entrance for the alerts panel

## Module 9: AWS + AI upgrade path

What you learn:
1. API Gateway + Lambda + DynamoDB mapping
2. SNS/Pinpoint notifications
3. AI anomaly/risk scoring roadmap

Where in docs:
1. `docs/aws-ai-architecture.md`

Practice:
1. Write cloud deployment plan for your own AWS account
2. List costs for MVP monthly usage

## Completion checklist

1. You can explain every endpoint without looking.
2. You can rebuild auth + circles + trip APIs from scratch.
3. You can add one new safety rule by yourself.
4. You can demo app live and explain architecture confidently.
