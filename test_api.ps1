$ErrorActionPreference = 'Continue'

Write-Host "Testing API endpoints..." -ForegroundColor Green

# Test the API
$url1 = "https://cdn.islamic.network/quran/audio/128/ar.alafasy/001001.mp3"
Write-Host "Testing: $url1" -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri $url1 -Method Head -TimeoutSec 10 -UseBasicParsing
    Write-Host "SUCCESS: Status $($response.StatusCode)" -ForegroundColor Green
}
catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
}
