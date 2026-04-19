param(
  [string]$ApiBase = "https://6rpyxxaw7c.execute-api.ap-south-1.amazonaws.com/api/v1",
  [string]$Bucket = "safety-copilot-ui-119944160349-20260410111252",
  [string]$CloudFrontId = "E26X5A8F8VF1LP"
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$frontendRoot = Resolve-Path (Join-Path $scriptDir "..")

Push-Location $frontendRoot
try {
  Write-Host "Building frontend with API base: $ApiBase"
  $env:VITE_API_BASE = $ApiBase
  npm run build

  Write-Host "Syncing static build to S3 bucket: $Bucket"
  aws s3 sync dist "s3://$Bucket" --delete
  aws s3 cp privacy-policy.html "s3://$Bucket/privacy-policy.html" --content-type text/html

  if ($CloudFrontId) {
    Write-Host "Invalidating CloudFront cache: $CloudFrontId"
    aws cloudfront create-invalidation --distribution-id $CloudFrontId --paths "/*" > $null
  }

  $cdnDomain = (aws cloudfront get-distribution --id $CloudFrontId | ConvertFrom-Json).Distribution.DomainName
  $s3Url = "http://$Bucket.s3-website.ap-south-1.amazonaws.com"

  Write-Host ""
  Write-Host "Live deployment complete:"
  Write-Host "S3 URL: $s3Url"
  Write-Host "CDN URL: https://$cdnDomain"
  Write-Host "Privacy policy: $s3Url/privacy-policy.html"
}
finally {
  Pop-Location
}
