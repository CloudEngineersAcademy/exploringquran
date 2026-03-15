# 📥 How to Download and Add Real Quran Audio Files

The audio directory structure has been created with placeholder files. Now you need to add real Quran audio files to make the player work.

## Quick Summary

- ✅ **Placeholder files created**: Located in `audio/` directory
- ❌ **Not working yet**: You need to download and replace with real audio
- ⏱️ **Time needed**: 30-60 minutes (depending on download speed)

---

## Best Option: Download from Everyayah.com

### Step 1: Visit the Website
Go to: **https://everyayah.com/**

### Step 2: Choose Your Reciter

Look for these folders:

| Folder Name in UI | Code | Quality | Size |
|---|---|---|---|
| Mishary Rashid Alafasy | `alafasy` | 128 kbps | ~500 MB |
| Abdul Rahman Al-Sudais | `sudais` | 128 kbps | ~500 MB |
| Mohamed El-Minshawi | `minshawi` | 128 kbps | ~500 MB |
| Ahmed Al-Ajmi | `ajmi` | 128 kbps | ~500 MB |

### Step 3: Download Audio Files

1. Click on the reciter folder
2. Select all 114 Surah files (Surah 1-114)
3. Download them (usually as a ZIP file)

### Step 4: Extract and Copy Files

1. Extract the downloaded ZIP
2. You should see files like: `001.mp3`, `002.mp3`, ..., `114.mp3`
3. Copy all files to the appropriate folder:
   ```
   audio/alafasy/       (if you downloaded Alafasy)
   audio/sudais/        (if you downloaded Al-Sudais)
   audio/minshawi/      (if you downloaded El-Minshawi)
   audio/ajmi/          (if you downloaded Al-Ajmi)
   ```

### Step 5: Test

1. Open `index.html` in your browser
2. Go to **Tools > Developer Console** (F12)
3. Select a Surah and click play
4. Check the console for any errors

### Step 6: Push to GitHub

```powershell
cd exploringurandotca
git add audio/
git commit -m "Add Quran audio files for [reciter_name]"
git push origin main
```

---

## Alternative Sources

### Option 2: Archive.org
- URL: https://archive.org/
- Search for: "Quran recitation [reciter name]"
- Download complete collection
- Follow Step 4 above

### Option 3: Direct Downloads
- **Quran Urdu**: https://quranurdu.com/ (limited selection)
- **Assimalhakeem.net**: Limited free downloads
- Individual reciter websites

---

## Automation Setup (Advanced)

Once you have identified a working API or source, you can:

### Create Custom Downloader Script

Save as `download_custom_audio.ps1`:

```powershell
$apiBase = 'https://YOUR_API_HERE'  # Replace with working API
$reciters = @{
    'alafasy' = 'YOUR_API_CODE'     # Check API documentation
}

$audioDir = Join-Path $PSScriptRoot 'audio'

foreach ($reciter in $reciters.Keys) {
    $dir = Join-Path $audioDir $reciter
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    
    for ($i = 1; $i -le 114; $i++) {
        $num = $i.ToString('000')
        $url = "$apiBase/$($reciters[$reciter])/${num}.mp3"
        $out = Join-Path $dir "$num.mp3"
        
        try {
            Invoke-WebRequest -Uri $url -OutFile $out -TimeoutSec 30
            Write-Host "✓ $reciter - Surah $i"
        }
        catch {
            Write-Host "✗ $reciter - Surah $i"
        }
    }
}
```

---

## File Structure Expected

```
exploringurandotca/
├── audio/
│   ├── alafasy/
│   │   ├── 001.mp3  (Surah 1: Al-Fatihah)
│   │   ├── 002.mp3  (Surah 2: Al-Baqarah)
│   │   ├── 003.mp3
│   │   └── ... (up to 114.mp3)
│   │
│   ├── sudais/
│   │   ├── 001.mp3
│   │   ├── 002.mp3
│   │   └── ... (up to 114.mp3)
│   │
│   ├── minshawi/
│   └── ajmi/
│
├── index.html  (Your Quran reader)
└── ...
```

---

## Troubleshooting

### Files Won't Download

**Symptom**: Download script fails for all files  
**Solution**:
- Check internet connection
- Verify API/URL is correct and accessible
- Try different source (everyayah.com, archive.org)
- Some APIs may have rate limiting - try again later

### Audio Won't Play (404 Error)

**Symptom**: "Audio file not found" error in browser  
**Solution**:
- Verify files exist: `ls audio/alafasy/` should show 114 MP3 files
- Check file sizes - should be > 1 MB per file
- Verify correct directory structure

### Filenames Wrong

**Symptom**: Audio plays wrong Surah  
**Solution**:
- Rename to format: `001.mp3`, `002.mp3`, etc.
- Use 3-digit numbering with leading zeros
- Example: Surah 5 should be named `005.mp3` (not `5.mp3`)

### GitHub Upload Too Large

**Symptom**: `git push` fails with size error  
**Solution**:
- Audio files are typically 2 GB total for 4 reciters
- GitHub allows large files via Git LFS
- Or: Remove audio from this repo and host separately
- Update `index.html` to link to external audio CDN

---

## Next Steps

1. ✅ Download audio from everyayah.com or similar
2. ✅ Replace placeholder files with real audio
3. ✅ Test in browser (F12 console for errors)
4. ✅ Push to GitHub
5. ✅ Enable GitHub Pages in repository settings
6. ✅ Share your Islamic education platform!

---

**Questions?** Check the console (F12) for specific error messages, or refer to troubleshooting section above.
