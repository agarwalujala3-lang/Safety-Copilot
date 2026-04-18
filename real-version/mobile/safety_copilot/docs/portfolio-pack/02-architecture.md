# 02 - Architecture

```mermaid
flowchart TD
  A[Flutter Android App] --> B[REST API - AWS Lambda]
  A --> C[Device Context Service]
  C --> D[Location + Battery + Permission Layer]
  B --> E[Trip Engine]
  E --> F[Alerts Store]
  E --> G[Trips/Locations Store]
  B --> H[Auth + Circles + Devices Endpoints]
  A --> I[Local Notifications]
```

## Mobile
- Flutter app with `dev` and `prod` flavors
- State management via Provider
- Core modules: Auth, Circles, Trip, Alerts, SOS, Device heartbeat

## Backend
- Node.js API on Lambda
- Endpoints:
  - `/auth/*`
  - `/circles/*`
  - `/trips/*`
  - `/alerts/my`, `/alerts/:id/ack`
  - `/devices/register`, `/devices/heartbeat`, `/devices/my`

## Cloud
- API hosted via Lambda URL
- Frontend hosted on S3 static website
- Deployment artifacts in S3 bucket
- Planned durable migration: DynamoDB-backed runtime store
