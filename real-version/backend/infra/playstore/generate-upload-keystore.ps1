$ErrorActionPreference = "Stop"

param(
  [string]$OutputDir = "C:\Users\AKSHYA\OneDrive\Desktop\UJALA\animation\learning-safety-app\real-version\mobile\safety_copilot\android\app",
  [string]$Alias = "safetycopilot",
  [string]$KeystorePassword = "change-me",
  [string]$KeyPassword = "change-me"
)

$keytool = "${env:JAVA_HOME}\bin\keytool.exe"
if (!(Test-Path $keytool)) {
  throw "keytool not found. Install JDK and set JAVA_HOME."
}

$keystorePath = Join-Path $OutputDir "upload-keystore.jks"

& $keytool -genkeypair `
  -v `
  -storetype JKS `
  -keystore $keystorePath `
  -alias $Alias `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -storepass $KeystorePassword `
  -keypass $KeyPassword `
  -dname "CN=Safety Copilot, OU=Engineering, O=Safety Copilot, L=Bengaluru, S=Karnataka, C=IN"

Write-Host "Keystore generated at: $keystorePath"
