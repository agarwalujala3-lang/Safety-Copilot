# AWS Live Deployment (Current)

Last verified: 2026-04-19 (Asia/Calcutta)

## Live URLs

1. Frontend (live, HTTPS CDN): `https://d1j7xq1aihw0g3.cloudfront.net`
2. Frontend (S3 origin): `http://safety-copilot-ui-119944160349-20260410111252.s3-website.ap-south-1.amazonaws.com`
3. Privacy policy (live): `http://safety-copilot-ui-119944160349-20260410111252.s3-website.ap-south-1.amazonaws.com/privacy-policy.html`
4. Backend API (primary): `https://6rpyxxaw7c.execute-api.ap-south-1.amazonaws.com/api/v1`
5. Backend health (primary): `https://6rpyxxaw7c.execute-api.ap-south-1.amazonaws.com/health`
6. Backend Lambda URL (legacy, still reachable): `https://yegajpcluzigy6ffamfvwopxry0ejyao.lambda-url.ap-south-1.on.aws/api/v1`

## AWS resources created

1. Lambda function: `safety-copilot-backend`
2. Lambda role: `safety-copilot-lambda-role`
3. S3 static bucket: `safety-copilot-ui-119944160349-20260410111252`
4. Lambda deploy artifact bucket: `safety-copilot-deploy-119944160349-20260410`
5. API Gateway HTTP endpoint: `6rpyxxaw7c.execute-api.ap-south-1.amazonaws.com`
6. CloudFront distribution: `E26X5A8F8VF1LP` (`d1j7xq1aihw0g3.cloudfront.net`)
7. Region: `ap-south-1`

## Live API surface highlights

1. Existing:
- `/auth/*`
- `/circles/*`
- `/trips/*`
- `/alerts/my`
2. New mobile endpoints:
- `POST /devices/register`
- `POST /devices/heartbeat`
- `GET /devices/my`
- `POST /alerts/:alertId/ack`

## Important note

Current backend persistence still uses JSON in Lambda `/tmp` fallback for demo speed.
For production durability, move store layer to DynamoDB or RDS.

## Update workflow

1. Backend:
- `.\infra\lambda\deploy.ps1`
- if direct upload fails, upload zip to S3 and run `aws lambda update-function-code --s3-bucket ...`

2. Frontend:
- recommended single command (from `real-version/frontend`):
  - `.\scripts\deploy-live.ps1`
- script steps:
  - `npm run build` with `VITE_API_BASE=https://6rpyxxaw7c.execute-api.ap-south-1.amazonaws.com/api/v1`
  - `aws s3 sync dist s3://<bucket> --delete`
  - `aws s3 cp privacy-policy.html s3://<bucket>/privacy-policy.html --content-type text/html`
  - `aws cloudfront create-invalidation --distribution-id E26X5A8F8VF1LP --paths "/*"`

3. Mobile (Flutter Android):
- `flutter pub get`
- `flutter run --flavor dev --dart-define=FLAVOR=dev --dart-define=API_BASE_URL=<live api>`
- `flutter build appbundle --flavor prod --dart-define=FLAVOR=prod --dart-define=API_BASE_URL=<live api>`
