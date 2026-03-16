# Simple Sequential Quran Audio Downloader
# Downloads all 114 Surahs for multiple Quran reciters

$ErrorActionPreference = 'Continue'

# Configure reciters
$RECITERS = @{
    'alafasy' = 'ar.alafasy'
    'sudais' = 'ar.abdulsamad'
    'minshawi' = 'ar.minshawi'
    'ajmi' = 'ar.ajmi'
}

$BASE_AUDIO_DIR = Join-Path $PSScriptRoot 'audio'
$API_BASE_URL = 'https://cdn.islamic.network/quran/audio/128'

Write-Host "`n" -ForegroundColor Green
Write-Host "🎵 QURAN AUDIO DOWNLOADER" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Reciters: $($RECITERS.Count)"
Write-Host "Surahs per reciter: 114"
Write-Host "Total files: $([int]114 * $RECITERS.Count)" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

# Create audio directories
Write-Host "Creating directories..." -ForegroundColor Yellow
foreach ($reciter in $RECITERS.Keys) {
    $dir = Join-Path $BASE_AUDIO_DIR $reciter
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}
Write-Host "✓ Directories created`n" -ForegroundColor Green

# Download files
$success = 0
$failed = 0
$totalSize = 0
$startTime = Get-Date

foreach ($reciter in $RECITERS.Keys) {
    $apiCode = $RECITERS[$reciter]
    Write-Host "Downloading $reciter..." -ForegroundColor Cyan
    
    for ($surah = 1; $surah -le 114; $surah++) {
        $surahStr = $surah.ToString('000')
        $url = "$API_BASE_URL/$apiCode/${surahStr}001.mp3"
        $filePath = Join-Path $BASE_AUDIO_DIR $reciter "$surahStr.mp3"
        
        try {
            Invoke-WebRequest -Uri $url -OutFile $filePath -TimeoutSec 30 -UseBasicParsing -ErrorAction Stop | Out-Null
            
            $fileSize = (Get-Item $filePath).Length / 1MB
            $totalSize += $fileSize
            $success++
            
            if ($surah % 30 -eq 0) {
                Write-Host "  ✓ Surah $surah/114" -ForegroundColor Green
            }
        }
        catch {
            $failed++
            Write-Host "  ✗ Surah $surah - Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    $totalAttempts = $success + $failed
    Write-Host "  Done: $success/$totalAttempts files" -ForegroundColor Green
}

$elapsedTime = ((Get-Date) - $startTime).TotalSeconds

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "✅ DOWNLOAD COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Downloaded: $success files" -ForegroundColor Green
Write-Host "Failed: $failed files" -ForegroundColor $(if ($failed -eq 0) { 'Green' } else { 'Yellow' })
Write-Host "Total size: $([math]::Round($totalSize, 2)) MB" -ForegroundColor Green
Write-Host "Time: $([math]::Round($elapsedTime, 1)) seconds" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

if ($failed -eq 0) {
    Write-Host "All audio files ready for deployment!" -ForegroundColor Green
    Write-Host "Next: git add audio/ and git commit -m 'Add Quran audio files'" -ForegroundColor Cyan
}
