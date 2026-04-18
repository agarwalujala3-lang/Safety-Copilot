$ErrorActionPreference = "Stop"

param(
  [string]$Region = "ap-south-1",
  [string]$Prefix = "/safety-copilot/prod",
  [string]$TokenSecret = "",
  [string]$FirebaseServerKey = "",
  [string]$GoogleMapsApiKey = ""
)

if ($TokenSecret -eq "") {
  throw "TokenSecret is required."
}

function Put-SecureParam {
  param([string]$Name, [string]$Value)

  aws ssm put-parameter `
    --name $Name `
    --value $Value `
    --type SecureString `
    --overwrite `
    --region $Region | Out-Null

  Write-Host "Stored: $Name"
}

Put-SecureParam -Name "$Prefix/TOKEN_SECRET" -Value $TokenSecret

if ($FirebaseServerKey -ne "") {
  Put-SecureParam -Name "$Prefix/FIREBASE_SERVER_KEY" -Value $FirebaseServerKey
}

if ($GoogleMapsApiKey -ne "") {
  Put-SecureParam -Name "$Prefix/GOOGLE_MAPS_API_KEY" -Value $GoogleMapsApiKey
}

Write-Host "Parameter Store setup completed for prefix $Prefix."
