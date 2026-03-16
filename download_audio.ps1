# Quran Audio Downloader - Simple Version
$ErrorActionPreference = 'Continue'

# Reciter API mappings
$reciters = @{
    'alafasy' = 'ar.alafasy'
    'sudais' = 'ar.abdulsamad'
    'minshawi' = 'ar.minshawi'
    'ajmi' = 'ar.ajmi'
}

$audioDir = Join-Path $PSScriptRoot 'audio'
$apiBase = 'https://cdn.islamic.network/quran/audio/128'

Write-Host "`n========== QURAN AUDIO DOWNLOADER ==========" -ForegroundColor Green
Write-Host "Reciters: 4 | Surahs: 114 | Total files: 456" -ForegroundColor Green
Write-Host "==========================================`n" -ForegroundColor Green

# Create directories
foreach ($reciter in $reciters.Keys) {
    $dir = Join-Path $audioDir $reciter
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# Download files
$startTime = Get-Date
$totalSuccess = 0
$totalFailed = 0
$totalSize = 0

foreach ($reciter in $reciters.Keys) {
    $apiCode = $reciters[$reciter]
    Write-Host "Downloading $reciter..." -ForegroundColor Cyan
    $reciterSuccess = 0
    
    for ($i = 1; $i -le 114; $i++) {
        $num = $i.ToString('000')
        $url = "$apiBase/$apiCode/$($num)001.mp3"
        $outPath = Join-Path -Path (Join-Path -Path $audioDir -ChildPath $reciter) -ChildPath "$num.mp3"
        
        try {
            $before = Get-Date
            Invoke-WebRequest -Uri $url -OutFile $outPath -TimeoutSec 30 -UseBasicParsing -ErrorAction Stop | Out-Null
            $after = Get-Date
            $elapsed = ($after - $before).TotalSeconds
            
            $bytes = (Get-Item $outPath).Length
            $mb = $bytes / 1MB
            $totalSize += $mb
            $totalSuccess++
            $reciterSuccess++
            
            if ($i % 30 -eq 0 -or $i -eq 114) {
                Write-Host "  $i/114 files" -ForegroundColor Green
            }
        }
        catch {
            $totalFailed++
            Write-Host "  Error on Surah $i" -ForegroundColor Red
        }
    }
    Write-Host "  Completed: $reciterSuccess/114`n" -ForegroundColor Green
}

$elapsed = ((Get-Date) - $startTime).TotalSeconds

Write-Host "==========================================`n" -ForegroundColor Green
Write-Host "SUCCESS: $totalSuccess files downloaded" -ForegroundColor Green
Write-Host "FAILED: $totalFailed files" -ForegroundColor Green
Write-Host "SIZE: $([math]::Round($totalSize, 2)) MB" -ForegroundColor Green
Write-Host "TIME: $([math]::Round($elapsed, 1)) seconds" -ForegroundColor Green
Write-Host "==========================================`n" -ForegroundColor Green

Write-Host "Audio files ready! Check the 'audio/' directory." -ForegroundColor Green
