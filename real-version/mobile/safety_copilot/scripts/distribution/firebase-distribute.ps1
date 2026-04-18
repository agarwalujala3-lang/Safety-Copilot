param(
  [Parameter(Mandatory=$true)][string]$FirebaseAppId,
  [Parameter(Mandatory=$true)][string]$Groups,
  [string]$ReleaseNotes = "Safety Copilot internal build"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$apk = Join-Path $root "releases\android\v1.0.0+1\safety-copilot-v1.0.0+1-prod-release.apk"

if (!(Test-Path $apk)) {
  throw "APK not found: $apk"
}

firebase appdistribution:distribute $apk --app $FirebaseAppId --groups $Groups --release-notes $ReleaseNotes
Write-Host "Distribution complete."
