# 06 - Interview / Viva Q&A

## Q1: Why Flutter?
Flutter enabled fast Android-first delivery with a single codebase and native performance characteristics.

## Q2: How is safety handled in low-connectivity scenarios?
The app sends heartbeat + location updates and backend rules generate offline-risk alerts when heartbeats stop.

## Q3: How do you avoid noisy alerts?
Alert generation applies throttling windows per alert type and trip context.

## Q4: Why silent SOS?
Some scenarios require discreet help requests without drawing attention.

## Q5: What are production gaps?
- Durable runtime persistence migration to DynamoDB
- Full Firebase Messaging integration
- In-app account deletion flow
- Observability dashboards and alarms hardening

## Q6: How did you secure app distribution?
Signed release artifacts with dedicated upload keystore and integrity checks via SHA256.
