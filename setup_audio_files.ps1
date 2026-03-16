# Create placeholder audio files for development/testing
# Users should replace these with real Quran audio files

$ErrorActionPreference = 'Continue'

$audioDir = Join-Path $PSScriptRoot 'audio'

# Reciters to setup
$reciters = @(
    'alafasy',
    'sudais',
    'minshawi',
    'ajmi'
)

Write-Host "`n========== AUDIO FILE SETUP ==========" -ForegroundColor Green
Write-Host "Setting up audio file structure for testing..." -ForegroundColor Yellow
Write-Host ""

# Create directories and placeholder files
foreach ($reciter in $reciters) {
    $reciterDir = Join-Path $audioDir $reciter
    New-Item -ItemType Directory -Path $reciterDir -Force | Out-Null
    
    Write-Host "Setting up $reciter..." -ForegroundColor Cyan
    
    for ($i = 1; $i -le 114; $i++) {
        $num = $i.ToString('000')
        $filePath = Join-Path $reciterDir "$num.mp3"
        
        # Create a minimal valid MP3 file (ID3 header)
        # This is a valid but silent/empty MP3 that can be tested
        $id3Header = [byte[]]@(0x49, 0x44, 0x33, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
        [System.IO.File]::WriteAllBytes($filePath, $id3Header)
        
        if ($i % 30 -eq 0 -or $i -eq 114) {
            Write-Host "  Created $i/114 files"
        }
    }
    
    Write-Host "  ✓ $reciter setup complete" -ForegroundColor Green
}

Write-Host "`n========== SETUP COMPLETE ==========" -ForegroundColor Green
Write-Host "Files created: $([int]114 * $reciters.Count) placeholder audio files" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Visit: https://everyayah.com/" -ForegroundColor White
Write-Host "2. Download Quran recitations for your preferred reciters" -ForegroundColor White
Write-Host "3. Extract and rename to match format: 001.mp3, 002.mp3, etc." -ForegroundColor White
Write-Host "4. Place in: audio/{reciter}/" -ForegroundColor White
Write-Host "5. Commit and push to GitHub" -ForegroundColor White
Write-Host ""
Write-Host "Alternative sources:" -ForegroundColor Yellow
Write-Host "- https://archive.org/search.php?query=quran+recitation" -ForegroundColor White
Write-Host "- https://quranurdu.com" -ForegroundColor White
Write-Host ""
