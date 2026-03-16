# 🎵 Quran Audio Setup Guide

## How to Host Quran Audio Files on GitHub

### Directory Structure
```
audio/
├── alafasy/          # Mishary Rashid Alafasy
│   ├── 001.mp3       # Surah 1 (Al-Fatihah)
│   ├── 002.mp3       # Surah 2 (Al-Baqarah)
│   └── ...
├── sudais/           # Abdul Rahman Al-Sudais
└── minshawi/         # Mohamed El-Minshawi
```

---

## Where to Find Quality MP3 Files

### Option 1: Download from Islamic.network API
```bash
# Download single Surah audio (Mishary Alafasy, Surah 1)
curl https://cdn.islamic.network/quran/audio/128/ar.alafasy/001001.mp3 -o audio/alafasy/001.mp3
```

### Option 2: Use Python Script to Download All
```python
import requests
import os

# Create directories
os.makedirs('audio/alafasy', exist_ok=True)

# Download all 114 Surahs for Mishary Alafasy
for surah in range(1, 115):
    surah_str = str(surah).zfill(3)
    url = f'https://cdn.islamic.network/quran/audio/128/ar.alafasy/{surah_str}001.mp3'
    filename = f'audio/alafasy/{surah_str}.mp3'
    
    print(f'Downloading Surah {surah}...')
    response = requests.get(url)
    
    if response.status_code == 200:
        with open(filename, 'wb') as f:
            f.write(response.content)
        print(f'✓ Saved: {filename}')
    else:
        print(f'✗ Failed: {url}')
```

### Option 3: Download from Everyayah.com
Visit: https://everyayah.com/
- Download your preferred reciter's complete set
- Extract the files
- Rename them to match our structure (001.mp3, 002.mp3, etc.)

### Option 4: Use Archive.org
Search for Quran recitations on:
https://archive.org/search.php?query=quran+recitation+al+sudais

---

## Steps to Add Audio Files

### 1. Download Audio Files
Choose your method from above and download MP3 files for each Surah

### 2. Add to Repository
```bash
# Copy your downloaded files to the audio directory
# Example: 
# cp /Downloads/alafasy/*.mp3 audio/alafasy/

# Rename files to match format: 001.mp3, 002.mp3, etc.
# Surah number should be 3 digits with leading zeros
```

### 3. Add to Git
```bash
cd audio/
git add alafasy/
git commit -m "Add Mishary Alafasy Quran audio files"
git push origin main
```

### 4. Files Should Be Named As:
```
audio/alafasy/001.mp3  # Surah 1
audio/alafasy/002.mp3  # Surah 2
audio/alafasy/003.mp3  # Surah 3
...
audio/alafasy/114.mp3  # Surah 114
```

---

## GitHub File Size Considerations

| Scenario | Size | Feasible |
|----------|------|----------|
| 1 Reciter (128kbps) | ~570 MB | ✅ Yes (under 2GB limit) |
| 2 Reciters | ~1.1 GB | ⚠️ Maybe (approaching limit) |
| 5 Reciters | ~2.8 GB | ❌ No (exceeds limits) |

**Recommendation:** Start with 1-2 reciters at 128kbps quality

---

## Alternative: Use CDN + GitHub

If GitHub file limits are an issue, we can:
1. Keep code on GitHub
2. Host audio files on:
   - Vercel (free static hosting)
   - Netlify (free static hosting)
   - AWS S3 (free tier)
   - Archive.org

---

## Code Configuration

The application is configured to look for audio files at:
```
https://CloudEngineersAcademy.github.io/exploringquran/audio/{reciter}/{surah}.mp3
```

### Reciters Supported:
```javascript
{
    'mishary': 'alafasy',
    'sudais': 'sudais',
    'minshawi': 'minshawi',
    'husary': 'husary',
    'muaiqly': 'muaiqly'
}
```

### Surah files should be numbered:
- 001.mp3 (Surah Al-Fatihah)
- 002.mp3 (Surah Al-Baqarah)
- ...
- 114.mp3 (Surah An-Nas)

---

## Testing

Once files are uploaded, test by:
1. Go to: https://CloudEngineersAcademy.github.io/exploringquran
2. Select a Surah
3. Click "Play"
4. Audio should play directly from GitHub

---

## Troubleshooting

**Audio won't play:**
- Check file exists at expected URL
- Verify file naming (001.mp3 format)
- Check browser console for 404 errors
- Test URL directly in browser: 
  ```
  https://CloudEngineersAcademy.github.io/exploringquran/audio/alafasy/001.mp3
  ```

**Files too large:**
- Compress MP3s to lower bitrate (64kbps instead of 128kbps)
- Upload only select Surahs first
- Use alternative CDN for full library

---

## Next Steps

1. Choose a reciter to download
2. Download or convert to 128kbps MP3s
3. Add files to `audio/{reciter}/` directory
4. Test the website
5. Add more reciters as needed
