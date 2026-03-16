# Setup audio file placeholder structure
$audioDir = Join-Path $PSScriptRoot 'audio'

Write-Host "Creating audio directory structure..." -ForegroundColor Green

$reciters = @('alafasy', 'sudais', 'minshawi', 'ajmi')

foreach ($reciter in $reciters) {
    $dir = Join-Path $audioDir $reciter
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Write-Host "Creating audio files for $reciter..." -ForegroundColor Cyan
    
    for ($i = 1; $i -le 114; $i++) {
        $num = $i.ToString('000')
        $file = Join-Path -Path $dir -ChildPath "$num.mp3"
        $header = [byte[]]@(0x49, 0x44, 0x33, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
        [System.IO.File]::WriteAllBytes($file, $header)
    }
    Write-Host "  - Created 114 placeholder files"
}

Write-Host ""
Write-Host "Audio structure ready! Download real files from:" -ForegroundColor Green
Write-Host "https://everyayah.com/" -ForegroundColor Yellow
