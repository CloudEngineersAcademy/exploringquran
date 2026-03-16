# Quran Audio Downloader (PowerShell)
# Downloads all 114 Surahs for famous Quran reciters using Islamic.network API

param(
    [int]$MaxConcurrency = 10
)

# Configure reciters and their API codes
$RECITERS = @{
    'alafasy' = @{
        'name' = 'Mishary Rashid Alafasy'
        'api_code' = 'ar.alafasy'
        'quality' = '128'
    }
    'sudais' = @{
        'name' = 'Abdul Rahman Al-Sudais'
        'api_code' = 'ar.abdulsamad'
        'quality' = '128'
    }
    'minshawi' = @{
        'name' = 'Mohamed El-Minshawi'
        'api_code' = 'ar.minshawi'
        'quality' = '128'
    }
    'ajmi' = @{
        'name' = 'Ahmed Al-Ajmi'
        'api_code' = 'ar.ajmi'
        'quality' = '128'
    }
    'ghamadi' = @{
        'name' = 'Saud Al-Shuraim'
        'api_code' = 'ar.shuraim'
        'quality' = '128'
    }
}

# Base directory for audio files
$BASE_AUDIO_DIR = Join-Path $PSScriptRoot 'audio'

# Islamic.network API base URL
$API_BASE_URL = 'https://cdn.islamic.network/quran/audio'

Write-Host "`n" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Green
Write-Host "🎵 QURAN AUDIO DOWNLOADER (PowerShell)" -ForegroundColor Green
Write-Host "=" * 70 -ForegroundColor Green
Write-Host "Total Surahs: 114"
Write-Host "Total Reciters: $($RECITERS.Count)"
Write-Host "Total Files: $([int]114 * $RECITERS.Count)"
Write-Host "=" * 70 -ForegroundColor Green
Write-Host "`n"

# Create directories
Write-Host "Creating directories..." -ForegroundColor Yellow
foreach ($reciter in $RECITERS.Keys) {
    $dir = Join-Path $BASE_AUDIO_DIR $reciter
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Write-Host "✓ Directory: $dir" -ForegroundColor Green
}

Write-Host "`nStarting downloads..." -ForegroundColor Yellow
Write-Host "Max concurrent downloads: $MaxConcurrency`n" -ForegroundColor Yellow

# Initialize counters
$global:successCount = 0
$global:errorCount = 0
$global:totalSize = 0
$global:totalFiles = 114 * $RECITERS.Count
$global:downloadedFiles = 0
$lock = New-Object System.Object

# Function to download a single Surah
function Download-Surah {
    param(
        [string]$ReciterFolder,
        [hashtable]$ReciterConfig,
        [int]$SurahNumber
    )
    
    $surahStr = $SurahNumber.ToString('000')
    $url = "$API_BASE_URL/$($ReciterConfig['quality'])/$($ReciterConfig['api_code'])/${surahStr}001.mp3"
    $filePath = Join-Path $BASE_AUDIO_DIR $ReciterFolder "$surahStr.mp3"
    
    try {
        $response = Invoke-WebRequest -Uri $url -OutFile $filePath -ErrorAction Stop -TimeoutSec 30 -UseBasicParsing
        
        # Get file size
        $fileSize = (Get-Item $filePath).Length / 1MB
        
        [System.Threading.Monitor]::Enter($lock)
        $global:successCount++
        $global:totalSize += $fileSize
        $global:downloadedFiles++
        
        $percent = [math]::Round(($global:downloadedFiles / $global:totalFiles) * 100, 0)
        Write-Host "[${percent}%] ✓ $($ReciterFolder.ToUpper()) - Surah $($surahStr) ($([math]::Round($fileSize, 2)) MB)" -ForegroundColor Green
        [System.Threading.Monitor]::Exit($lock)
        
        return $true
    }
    catch {
        [System.Threading.Monitor]::Enter($lock)
        $global:errorCount++
        $global:downloadedFiles++
        
        $percent = [math]::Round(($global:downloadedFiles / $global:totalFiles) * 100, 0)
        Write-Host "[${percent}%] ✗ $($ReciterFolder.ToUpper()) - Surah $($surahStr) - ERROR: $($_.Exception.Message)" -ForegroundColor Red
        [System.Threading.Monitor]::Exit($lock)
        
        return $false
    }
}

# Create download jobs
$jobs = @()
$scriptBlock = {
    param($ReciterFolder, $ReciterConfig, $SurahNumber, $BASE_AUDIO_DIR, $API_BASE_URL, $lock, $metrics)
    
    $surahStr = $SurahNumber.ToString('000')
    $url = "$API_BASE_URL/$($ReciterConfig['quality'])/$($ReciterConfig['api_code'])/${surahStr}001.mp3"
    $filePath = Join-Path $BASE_AUDIO_DIR $ReciterFolder "$surahStr.mp3"
    
    try {
        $response = Invoke-WebRequest -Uri $url -OutFile $filePath -ErrorAction Stop -TimeoutSec 30 -UseBasicParsing
        
        $fileSize = (Get-Item $filePath).Length / 1MB
        
        @{
            status = 'success'
            reciter = $ReciterFolder
            surah = $SurahNumber
            size_mb = $fileSize
        }
    }
    catch {
        @{
            status = 'error'
            reciter = $ReciterFolder
            surah = $SurahNumber
            error = $_.Exception.Message
        }
    }
}

# Submit all download jobs
Write-Host "Submitting download jobs..." -ForegroundColor Cyan

$allJobs = @()
foreach ($reciter in $RECITERS.Keys) {
    $reciterConfig = $RECITERS[$reciter]
    
    for ($surah = 1; $surah -le 114; $surah++) {
        $job = Start-Job -ScriptBlock $scriptBlock `
            -ArgumentList $reciter, $reciterConfig, $surah, $BASE_AUDIO_DIR, $API_BASE_URL, $lock, $null
        
        $allJobs += $job
        
        # Throttle concurrent jobs
        while ((Get-Job -State Running).Count -ge $MaxConcurrency) {
            Start-Sleep -Milliseconds 100
        }
    }
}

Write-Host "Submitted $($allJobs.Count) download jobs. Monitoring progress...`n" -ForegroundColor Cyan

# Monitor job completion
$completedJobs = 0
$results = @{
    success = 0
    error = 0
    total_size_mb = 0
    by_reciter = @{}
}

foreach ($reciter in $RECITERS.Keys) {
    $results.by_reciter[$reciter] = @{
        success = 0
        error = 0
    }
}

$startTime = Get-Date

while ((Get-Job -State Running).Count -gt 0) {
    $completedJobs = (Get-Job -State Completed).Count
    $percent = [math]::Round(($completedJobs / $allJobs.Count) * 100, 0)
    Write-Host "[${percent}%] Processing: $completedJobs/$($allJobs.Count) jobs completed..." -ForegroundColor Cyan -NoNewline
    Write-Host "`r" -NoNewline
    Start-Sleep -Seconds 1
}

Write-Host "`n" -ForegroundColor Cyan

# Collect results
Write-Host "Collecting results..." -ForegroundColor Yellow

foreach ($job in $allJobs) {
    $result = Receive-Job -Job $job
    $completedJobs++
    $percent = [math]::Round(($completedJobs / $allJobs.Count) * 100, 0)
    
    if ($result.status -eq 'success') {
        $results.success++
        $results.by_reciter[$result.reciter].success++
        $results.total_size_mb += $result.size_mb
        Write-Host "[${percent}%] ✓ $($result.reciter.ToUpper()) - Surah $($result.surah.ToString('000')) ($([math]::Round($result.size_mb, 2)) MB)" -ForegroundColor Green
    }
    else {
        $results.error++
        $results.by_reciter[$result.reciter].error++
        Write-Host "[${percent}%] ✗ $($result.reciter.ToUpper()) - Surah $($result.surah.ToString('000')) - ERROR" -ForegroundColor Red
    }
    
    Remove-Job -Job $job
}

$elapsedTime = ((Get-Date) - $startTime).TotalSeconds

# Print summary
Write-Host "`n" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Green
Write-Host "📊 DOWNLOAD SUMMARY" -ForegroundColor Green
Write-Host "=" * 70 -ForegroundColor Green
Write-Host "Total files downloaded: $($results.success)" -ForegroundColor Green
Write-Host "Total errors: $($results.error)" -ForegroundColor $(if ($results.error -eq 0) { 'Green' } else { 'Yellow' })
Write-Host "Total size: $([math]::Round($results.total_size_mb, 2)) MB" -ForegroundColor Green
Write-Host "Time elapsed: $([math]::Round($elapsedTime, 1)) seconds" -ForegroundColor Green
Write-Host "=" * 70 -ForegroundColor Green

Write-Host "`nBreakdown by reciter:" -ForegroundColor Cyan
foreach ($reciter in $RECITERS.Keys) {
    $success = $results.by_reciter[$reciter].success
    $error = $results.by_reciter[$reciter].error
    Write-Host "  $($reciter.ToUpper().PadRight(12)) - ✓ $($success.ToString().PadLeft(3))/114  ✗ $($error.ToString().PadLeft(3))" -ForegroundColor $(if ($error -eq 0) { 'Green' } else { 'Yellow' })
}

Write-Host "`n" + "=" * 70 -ForegroundColor Green

if ($results.error -eq 0) {
    Write-Host "`n✅ All downloads completed successfully!" -ForegroundColor Green
    Write-Host "Audio files are ready in 'audio/' directory." -ForegroundColor Green
    Write-Host "Next step: Push to GitHub`n" -ForegroundColor Green
}
else {
    Write-Host "`n⚠️  Some downloads failed. Try running this script again." -ForegroundColor Yellow
    Write-Host "Partial results: $($results.success) files downloaded`n" -ForegroundColor Yellow
}
