# Real Backend

This version uses a cleaner architecture:

1. Routes for HTTP mapping
2. Controllers for request/response orchestration
3. Services for business logic
4. Store for persistence

## Start

```bash
npm install
npm run dev
```

Server: `http://localhost:4002`

## Versioned API (`/api/v1`)

### Auth
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `GET /api/v1/auth/me`

### Trusted circle
- `POST /api/v1/circles`
- `POST /api/v1/circles/:circleId/members`
- `GET /api/v1/circles/my`

### Trip lifecycle
- `POST /api/v1/trips/start`
- `GET /api/v1/trips/active/me`
- `GET /api/v1/trips/:tripId`
- `GET /api/v1/trips/:tripId/locations`
- `POST /api/v1/trips/:tripId/location`
- `POST /api/v1/trips/:tripId/arrive`
- `POST /api/v1/trips/:tripId/end`
- `POST /api/v1/trips/:tripId/sos`

### Alerts
- `GET /api/v1/alerts/my`
- `POST /api/v1/alerts/:alertId/ack`

### Devices
- `POST /api/v1/devices/register`
- `POST /api/v1/devices/heartbeat`
- `GET /api/v1/devices/my`

## Built-in safety checks

1. Arrival detection with radius + stability window
2. Route deviation alerts from route polyline distance
3. Delay alerts based on ETA grace window
4. Low battery alerts
5. Offline alerts from heartbeat inactivity

## Infra scripts

Run from `backend` directory:

1. DynamoDB tables: `.\infra\dynamodb\create-tables.ps1`
2. JSON migration: `node .\infra\dynamodb\migrate-json-to-dynamodb.js`
3. Lambda deploy: `.\infra\lambda\deploy.ps1`
4. CloudWatch alarms: `.\infra\cloudwatch\create-alarms.ps1`
5. Parameter Store secrets: `.\infra\secrets\setup-parameter-store.ps1`
