$ErrorActionPreference = "Stop"

param(
  [string]$Region = "ap-south-1",
  [string]$FunctionName = "safety-copilot-backend",
  [string]$AlarmPrefix = "safety-copilot",
  [string]$SnsTopicArn = ""
)

function New-Alarm {
  param(
    [string]$AlarmName,
    [string]$MetricName,
    [string]$Statistic,
    [int]$Threshold,
    [string]$ComparisonOperator,
    [int]$Period,
    [int]$EvaluationPeriods
  )

  $args = @(
    "cloudwatch", "put-metric-alarm",
    "--alarm-name", $AlarmName,
    "--metric-name", $MetricName,
    "--namespace", "AWS/Lambda",
    "--statistic", $Statistic,
    "--period", $Period,
    "--threshold", $Threshold,
    "--comparison-operator", $ComparisonOperator,
    "--evaluation-periods", $EvaluationPeriods,
    "--dimensions", "Name=FunctionName,Value=$FunctionName",
    "--treat-missing-data", "notBreaching",
    "--region", $Region
  )

  if ($SnsTopicArn -ne "") {
    $args += @("--alarm-actions", $SnsTopicArn, "--ok-actions", $SnsTopicArn)
  }

  aws @args | Out-Null
  Write-Host "Alarm ready: $AlarmName"
}

New-Alarm -AlarmName "${AlarmPrefix}-lambda-errors" `
  -MetricName "Errors" -Statistic "Sum" -Threshold 1 `
  -ComparisonOperator "GreaterThanOrEqualToThreshold" -Period 60 -EvaluationPeriods 1

New-Alarm -AlarmName "${AlarmPrefix}-lambda-throttles" `
  -MetricName "Throttles" -Statistic "Sum" -Threshold 1 `
  -ComparisonOperator "GreaterThanOrEqualToThreshold" -Period 60 -EvaluationPeriods 1

New-Alarm -AlarmName "${AlarmPrefix}-lambda-duration-p95" `
  -MetricName "Duration" -Statistic "Average" -Threshold 1500 `
  -ComparisonOperator "GreaterThanThreshold" -Period 300 -EvaluationPeriods 2

Write-Host "CloudWatch alarms configured for $FunctionName."
