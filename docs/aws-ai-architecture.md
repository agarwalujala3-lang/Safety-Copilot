# AWS + AI Architecture for Safety Copilot

This document maps your project to a cloud-first, interview-ready architecture.

## 1) Mobile and identity

1. Mobile app (Flutter): user app + guardian app
2. `Amazon Cognito`: signup, login, JWT auth, device identity
3. `AWS AppConfig` or `SSM Parameter Store`: dynamic risk thresholds

## 2) API and compute

1. `Amazon API Gateway`: public API entrypoint
2. `AWS Lambda`: stateless business logic
3. Optional: `Amazon ECS Fargate` if you later need long-running services

## 3) Core data

1. `Amazon DynamoDB`
- users
- trusted circles
- trips
- location pings
- alerts
- safety events
2. `Amazon S3`
- incident exports (PDF, logs, snapshots)
3. `Amazon ElastiCache (Redis)` (optional)
- active trip state cache for fast alert checks

## 4) Live location + geospatial

1. `Amazon Location Service`
- map rendering
- routing
- geofencing (arrival zones, risk zones)
2. `Amazon EventBridge`
- trip state events (`trip.started`, `trip.arrived`, `trip.deviation`)

## 5) Notifications and escalation

1. `Amazon SNS`
- SMS fallback and high-priority fanout
2. `Amazon Pinpoint` or `Firebase` (push notifications)
3. `Amazon SES`
- email incident summaries

## 6) AI layer (what makes project stand out)

1. **Anomaly detection service**
- Input: recent location stream, speed changes, route deviation, offline windows
- Baseline MVP: rule engine in Lambda
- AI phase: `Amazon SageMaker` model for abnormal trip behavior scoring

2. **Risk scoring service**
- Input: route metadata + historical incident density + time-of-day
- Model options:
  - start with feature-weight rules
  - move to SageMaker/XGBoost for learned scoring

3. **Safety assistant (optional)**
- `Amazon Bedrock` to generate plain-language safety summaries:
  - "Route B is safer because..."
  - "Escalation triggered due to 3 risk signals..."

## 7) Observability and security

1. `CloudWatch` logs, metrics, alarms
2. `AWS X-Ray` tracing across API/Lambda
3. `AWS WAF` on API Gateway
4. `AWS KMS` encryption keys for sensitive fields
5. `AWS Secrets Manager` for API keys (maps, SMS, etc.)

## 8) Suggested phased rollout

### Phase A (MVP cloud)

1. Cognito + API Gateway + Lambda
2. DynamoDB + SNS + Location Service
3. Rule-based alerts (no ML yet)

### Phase B (AI-enhanced)

1. SageMaker anomaly model
2. Route risk prediction model
3. Bedrock safety explanation layer

### Phase C (production hardening)

1. Multi-region failover for critical alert path
2. SQS buffering for notification retries
3. Security audit + cost optimization

## 9) Interview one-liner

"I built a cloud-native safety intelligence app on AWS with real-time trip monitoring, geofence-based arrival confirmation, and AI-assisted anomaly/risk scoring for proactive escalation."
