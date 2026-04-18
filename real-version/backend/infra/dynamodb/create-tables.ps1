$ErrorActionPreference = "Stop"

param(
  [string]$Region = "ap-south-1",
  [string]$Prefix = "safety_copilot"
)

function Test-TableExists {
  param([string]$TableName, [string]$Region)
  aws dynamodb describe-table --table-name $TableName --region $Region > $null 2>&1
  return $LASTEXITCODE -eq 0
}

function Ensure-Table {
  param(
    [string]$TableName,
    [string]$Region,
    [string]$KeySchemaJson,
    [string]$AttributesJson
  )

  if (Test-TableExists -TableName $TableName -Region $Region) {
    Write-Host "Exists: $TableName"
    return
  }

  Write-Host "Creating: $TableName"
  aws dynamodb create-table `
    --table-name $TableName `
    --attribute-definitions $AttributesJson `
    --key-schema $KeySchemaJson `
    --billing-mode PAY_PER_REQUEST `
    --region $Region > $null

  aws dynamodb wait table-exists --table-name $TableName --region $Region
  Write-Host "Ready: $TableName"
}

$usersTable = "${Prefix}_users"
$circlesTable = "${Prefix}_circles"
$membersTable = "${Prefix}_circle_members"
$tripsTable = "${Prefix}_trips"
$locationsTable = "${Prefix}_trip_locations"
$alertsTable = "${Prefix}_alerts"
$devicesTable = "${Prefix}_devices"

Ensure-Table -TableName $usersTable -Region $Region `
  -AttributesJson "AttributeName=userId,AttributeType=S" `
  -KeySchemaJson "AttributeName=userId,KeyType=HASH"

Ensure-Table -TableName $circlesTable -Region $Region `
  -AttributesJson "AttributeName=circleId,AttributeType=S" `
  -KeySchemaJson "AttributeName=circleId,KeyType=HASH"

Ensure-Table -TableName $membersTable -Region $Region `
  -AttributesJson "AttributeName=circleId,AttributeType=S AttributeName=memberId,AttributeType=S" `
  -KeySchemaJson "AttributeName=circleId,KeyType=HASH AttributeName=memberId,KeyType=RANGE"

Ensure-Table -TableName $tripsTable -Region $Region `
  -AttributesJson "AttributeName=tripId,AttributeType=S" `
  -KeySchemaJson "AttributeName=tripId,KeyType=HASH"

Ensure-Table -TableName $locationsTable -Region $Region `
  -AttributesJson "AttributeName=tripId,AttributeType=S AttributeName=capturedAt,AttributeType=S" `
  -KeySchemaJson "AttributeName=tripId,KeyType=HASH AttributeName=capturedAt,KeyType=RANGE"

Ensure-Table -TableName $alertsTable -Region $Region `
  -AttributesJson "AttributeName=alertId,AttributeType=S" `
  -KeySchemaJson "AttributeName=alertId,KeyType=HASH"

Ensure-Table -TableName $devicesTable -Region $Region `
  -AttributesJson "AttributeName=userId,AttributeType=S AttributeName=deviceId,AttributeType=S" `
  -KeySchemaJson "AttributeName=userId,KeyType=HASH AttributeName=deviceId,KeyType=RANGE"

Write-Host "All DynamoDB tables are ready with prefix $Prefix in region $Region."
