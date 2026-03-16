# Debug Quran Audio Downloader
$ErrorActionPreference = 'Continue'

$reciter = 'alafasy'
$apiCode = 'ar.alafasy'
$apiBase = 'https://cdn.islamic.network/quran/audio/128'

# Test URLs
$testUrls = @(
    "$apiBase/$apiCode/001001.mp3",
    "https://cdn.islamic.network/quran/audio/128/ar.alafasy/001001.mp3",
    "https://everyayah.com/data/Mishari_Alafasy/001.mp3"
)

Write-Host "Testing API URLs..." -ForegroundColor Cyan
Write-Host ""

foreach ($url in $testUrls) {
    Write-Host "Testing: $url" -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
        Write-Host "  ✓ Success! (Status: $($response.StatusCode))" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
}

# Try downloading a single file
Write-Host "Attempting to download a sample file..." -ForegroundColor Cyan
$outPath = 'test_audio.mp3'

try {
    Invoke-WebRequest -Uri "https://cdn.islamic.network/quran/audio/128/ar.alafasy/001001.mp3" -OutFile $outPath -TimeoutSec 30 -UseBasicParsing -ErrorAction Stop
    if (Test-Path $outPath) {
        $size = (Get-Item $outPath).Length
        Write-Host "✓ Download successful! Size: $([math]::Round($size/1MB, 2)) MB" -ForegroundColor Green
        Remove-Item $outPath 2>$null
    }
}
catch {
    Write-Host "✗ Download failed: $($_.Exception.Message)" -ForegroundColor Red
}
