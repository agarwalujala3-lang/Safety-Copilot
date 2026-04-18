param(
  [string]$Region = "ap-south-1",
  [string]$FunctionName = "safety-copilot-backend",
  [string]$RoleArn = "arn:aws:iam::119944160349:role/safety-copilot-lambda-role",
  [string]$TokenSecret = "safety-copilot-prod-secret"
)

$ErrorActionPreference = "Stop"

$backendRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$deployDir = Join-Path $backendRoot ".deploy"
if (!(Test-Path $deployDir)) {
  New-Item -ItemType Directory -Path $deployDir | Out-Null
}
$zipPath = Join-Path $deployDir "backend-lambda.zip"
if (Test-Path $zipPath) {
  Remove-Item $zipPath -Force
}

Push-Location $backendRoot
Compress-Archive -Path @(
  "lambda.js",
  "src",
  "package.json",
  "package-lock.json",
  "node_modules",
  "data"
) -DestinationPath $zipPath -Force
Pop-Location

aws lambda get-function --function-name $FunctionName --region $Region > $null 2>&1
$exists = $LASTEXITCODE -eq 0

if ($exists) {
  aws lambda update-function-code --function-name $FunctionName --zip-file fileb://$zipPath --region $Region | Out-Null
  aws lambda update-function-configuration `
    --function-name $FunctionName `
    --handler lambda.handler `
    --runtime nodejs20.x `
    --timeout 30 `
    --memory-size 512 `
    --environment "Variables={TOKEN_SECRET=$TokenSecret}" `
    --region $Region | Out-Null
  Write-Host "Updated Lambda function: $FunctionName"
} else {
  aws lambda create-function `
    --function-name $FunctionName `
    --runtime nodejs20.x `
    --role $RoleArn `
    --handler lambda.handler `
    --timeout 30 `
    --memory-size 512 `
    --zip-file fileb://$zipPath `
    --environment "Variables={TOKEN_SECRET=$TokenSecret}" `
    --region $Region | Out-Null
  Write-Host "Created Lambda function: $FunctionName"
}

aws lambda wait function-active-v2 --function-name $FunctionName --region $Region

aws lambda get-function-url-config --function-name $FunctionName --region $Region > $null 2>&1
$hasUrl = $LASTEXITCODE -eq 0
if (!$hasUrl) {
  aws lambda create-function-url-config `
    --function-name $FunctionName `
    --auth-type NONE `
    --cors "AllowOrigins=['*'],AllowMethods=['*'],AllowHeaders=['*']" `
    --region $Region | Out-Null

  aws lambda add-permission `
    --function-name $FunctionName `
    --statement-id FunctionURLAllowPublicAccess `
    --action lambda:InvokeFunctionUrl `
    --principal "*" `
    --function-url-auth-type NONE `
    --region $Region | Out-Null

  aws lambda add-permission `
    --function-name $FunctionName `
    --statement-id PublicInvokeFunction `
    --action lambda:InvokeFunction `
    --principal "*" `
    --region $Region | Out-Null
}

$url = (aws lambda get-function-url-config --function-name $FunctionName --region $Region | ConvertFrom-Json).FunctionUrl
Write-Host "Backend URL: $url"
