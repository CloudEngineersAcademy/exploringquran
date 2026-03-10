# 🔌 API Integration Guide for Quran Explorer

## Overview

This guide provides detailed information about integrating Quran data and audio into your application using free and open Islamic APIs.

## Table of Contents
1. [Al-Quran Cloud API](#al-quran-cloud-api)
2. [Audio Integration](#audio-integration)
3. [Alternative APIs](#alternative-apis)
4. [Error Handling](#error-handling)
5. [Rate Limiting](#rate-limiting)
6. [Best Practices](#best-practices)

---

## Al-Quran Cloud API

### Base URL
```
https://api.alquran.cloud/v1/
```

### Authentication
No API key required - completely free!

### Endpoints

#### 1. Get Single Surah
```http
GET /surah/{surah_number}
```

**Example:**
```javascript
fetch('https://api.alquran.cloud/v1/surah/1')
  .then(response => response.json())
  .then(data => console.log(data));
```

**Response:**
```json
{
  "code": 200,
  "status": "OK",
  "data": {
    "number": 1,
    "name": "سُورَةُ ٱلْفَاتِحَةِ",
    "englishName": "Al-Faatiha",
    "englishNameTranslation": "The Opening",
    "revelationType": "Meccan",
    "numberOfAyahs": 7,
    "ayahs": [
      {
        "number": 1,
        "text": "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
        "numberInSurah": 1,
        "juz": 1,
        "manzil": 1,
        "page": 1,
        "ruku": 1,
        "hizbQuarter": 1,
        "sajda": false
      }
    ]
  }
}
```

#### 2. Get Surah with Translation
```http
GET /surah/{surah_number}/editions/{edition1},{edition2}
```

**Example:**
```javascript
// Get Arabic and English translation
fetch('https://api.alquran.cloud/v1/surah/1/editions/quran-uthmani,en.sahih')
  .then(response => response.json())
  .then(data => {
    const arabic = data.data[0];
    const translation = data.data[1];
    console.log(arabic, translation);
  });
```

#### 3. Get Single Ayah
```http
GET /ayah/{ayah_number}
```

**Example:**
```javascript
fetch('https://api.alquran.cloud/v1/ayah/1:1')
  .then(response => response.json())
  .then(data => console.log(data));
```

#### 4. Get All Surahs
```http
GET /surah
```

**Example:**
```javascript
fetch('https://api.alquran.cloud/v1/surah')
  .then(response => response.json())
  .then(data => console.log(data.data)); // Array of all surahs
```

#### 5. Search Quran
```http
GET /search/{keyword}/{surah_number}/{edition}
```

**Example:**
```javascript
// Search for "rahman" in all Quran
fetch('https://api.alquran.cloud/v1/search/rahman/all/en.sahih')
  .then(response => response.json())
  .then(data => console.log(data.data.matches));
```

#### 6. Get Juz
```http
GET /juz/{juz_number}
```

**Example:**
```javascript
fetch('https://api.alquran.cloud/v1/juz/1/quran-uthmani')
  .then(response => response.json())
  .then(data => console.log(data));
```

---

## Available Editions (Translations)

### Arabic Editions
| Code | Description |
|------|-------------|
| `quran-uthmani` | Uthmani script (standard) |
| `quran-simple` | Simple Arabic text |
| `ar.muyassar` | Arabic Tafsir Al-Muyassar |

### English Translations
| Code | Translator |
|------|-----------|
| `en.sahih` | Sahih International |
| `en.pickthall` | Mohammed Marmaduke Pickthall |
| `en.yusufali` | Abdullah Yusuf Ali |
| `en.asad` | Muhammad Asad |
| `en.arberry` | A. J. Arberry |

### Other Languages
| Code | Language | Translator |
|------|----------|-----------|
| `ur.jalandhry` | Urdu | Fateh Muhammad Jalandhry |
| `fr.hamidullah` | French | Muhammad Hamidullah |
| `id.indonesian` | Indonesian | Ministry of Religious Affairs |
| `tr.diyanet` | Turkish | Diyanet İşleri |
| `de.bubenheim` | German | Bubenheim & Elyas |
| `es.cortes` | Spanish | Julio Cortes |
| `ru.kuliev` | Russian | Elmir Kuliev |
| `bn.bengali` | Bengali | Muhiuddin Khan |
| `fa.makarem` | Persian | Makarem Shirazi |

---

## Audio Integration

### Audio CDN
```
https://cdn.islamic.network/quran/audio/
```

### Audio Quality Options
- **128 kbps**: `/128/` (Recommended)
- **64 kbps**: `/64/` (Lower quality, smaller size)

### File Naming Convention
```
{surah_number}{ayah_number}.mp3
```
- Both numbers are 3 digits with leading zeros
- Example: `001001.mp3` (Surah 1, Ayah 1)

### Available Reciters

| Code | Reciter Name |
|------|-------------|
| `ar.alafasy` | Mishary Rashid Alafasy |
| `ar.abdulbasitmurattal` | Abdul Basit Abdul Samad (Murattal) |
| `ar.minshawi` | Mohamed Siddiq El-Minshawi (Murattal) |
| `ar.minshawimujawwad` | Mohamed Siddiq El-Minshawi (Mujawwad) |
| `ar.husary` | Mahmoud Khalil Al-Hussary |
| `ar.husarymujawwad` | Mahmoud Khalil Al-Hussary (Mujawwad) |
| `ar.shaatree` | Abu Bakr Al-Shatri |
| `ar.muaiqly` | Maher Al Muaiqly |
| `ar.walk` | Abdullah Awad Al-Juhani |
| `ar.abdurrahmaansudais` | Abdul Rahman Al-Sudais |

### Audio URL Examples

```javascript
// Mishary Rashid Alafasy - Surah 1, Ayah 1
const audioUrl1 = 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/001001.mp3';

// Abdul Basit - Surah 2, Ayah 255 (Ayat al-Kursi)
const audioUrl2 = 'https://cdn.islamic.network/quran/audio/128/ar.abdulbasitmurattal/002255.mp3';

// Play audio
const audio = new Audio(audioUrl1);
audio.play();
```

### Complete Audio Player Implementation

```javascript
class QuranAudioPlayer {
  constructor() {
    this.audio = new Audio();
    this.currentSurah = 1;
    this.currentAyah = 1;
    this.reciter = 'ar.alafasy';
    this.isPlaying = false;
    
    // Setup event listeners
    this.audio.addEventListener('ended', () => this.nextAyah());
    this.audio.addEventListener('play', () => this.isPlaying = true);
    this.audio.addEventListener('pause', () => this.isPlaying = false);
    this.audio.addEventListener('error', (e) => this.handleError(e));
  }
  
  play(surah, ayah) {
    this.currentSurah = surah;
    this.currentAyah = ayah;
    
    const surahStr = String(surah).padStart(3, '0');
    const ayahStr = String(ayah).padStart(3, '0');
    const url = `https://cdn.islamic.network/quran/audio/128/${this.reciter}/${surahStr}${ayahStr}.mp3`;
    
    this.audio.src = url;
    this.audio.play();
  }
  
  pause() {
    this.audio.pause();
  }
  
  resume() {
    this.audio.play();
  }
  
  stop() {
    this.audio.pause();
    this.audio.currentTime = 0;
  }
  
  nextAyah() {
    // Get total ayahs in current surah
    const totalAyahs = this.getSurahAyahCount(this.currentSurah);
    
    if (this.currentAyah < totalAyahs) {
      this.play(this.currentSurah, this.currentAyah + 1);
    } else {
      // Move to next surah
      if (this.currentSurah < 114) {
        this.play(this.currentSurah + 1, 1);
      } else {
        this.stop();
      }
    }
  }
  
  previousAyah() {
    if (this.currentAyah > 1) {
      this.play(this.currentSurah, this.currentAyah - 1);
    } else if (this.currentSurah > 1) {
      const prevSurah = this.currentSurah - 1;
      const lastAyah = this.getSurahAyahCount(prevSurah);
      this.play(prevSurah, lastAyah);
    }
  }
  
  setReciter(reciterCode) {
    this.reciter = reciterCode;
  }
  
  handleError(error) {
    console.error('Audio playback error:', error);
    // Fallback or retry logic
  }
  
  getSurahAyahCount(surah) {
    const ayahCounts = [7,286,200,176,120,165,206,75,129,109,123,111,43,52,99,128,111,110,98,135,112,78,118,64,77,227,93,88,69,60,34,30,73,54,45,83,182,88,75,85,54,53,89,59,37,35,38,29,18,45,60,49,62,55,78,96,29,22,24,13,14,11,11,18,12,12,30,52,52,44,28,28,20,56,40,31,50,40,46,42,29,19,36,25,22,17,19,26,30,20,15,21,11,8,8,19,5,8,8,11,11,8,3,9,5,4,7,3,6,3,5,4,5,6];
    return ayahCounts[surah - 1];
  }
}

// Usage
const player = new QuranAudioPlayer();
player.play(1, 1); // Play Al-Fatihah, Ayah 1
```

---

## Alternative APIs

### 1. Quran.com API
```
https://api.quran.com/api/v4/
```

**Features:**
- More detailed metadata
- Chapter info, verses, translations
- Tafsir (commentary)
- Recitations with timestamps

**Example:**
```javascript
fetch('https://api.quran.com/api/v4/chapters/1')
  .then(response => response.json())
  .then(data => console.log(data));
```

### 2. Tanzil API
```
http://api.tanzil.net/
```

**Features:**
- Simple text API
- Multiple text types
- Download options

**Example:**
```javascript
fetch('http://api.tanzil.net/aya/surah/1/ayah/1')
  .then(response => response.text())
  .then(text => console.log(text));
```

### 3. GlobalQuran API
```
https://api.globalquran.com/
```

**Features:**
- Word-by-word translation
- Multiple reciters
- Translation comparisons

---

## Error Handling

### Network Errors
```javascript
async function fetchQuranData(surah) {
  try {
    const response = await fetch(`https://api.alquran.cloud/v1/surah/${surah}`);
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    
    if (data.code !== 200) {
      throw new Error(`API error: ${data.status}`);
    }
    
    return data.data;
  } catch (error) {
    console.error('Error fetching Quran data:', error);
    
    // Fallback to cached data
    return getCachedData(surah);
  }
}
```

### Audio Loading Errors
```javascript
audio.addEventListener('error', function(e) {
  switch (e.target.error.code) {
    case e.target.error.MEDIA_ERR_ABORTED:
      console.error('Audio loading aborted');
      break;
    case e.target.error.MEDIA_ERR_NETWORK:
      console.error('Network error while loading audio');
      // Retry with different quality
      retryAudio('64'); // Try 64kbps instead of 128kbps
      break;
    case e.target.error.MEDIA_ERR_DECODE:
      console.error('Audio decoding error');
      break;
    case e.target.error.MEDIA_ERR_SRC_NOT_SUPPORTED:
      console.error('Audio format not supported');
      break;
  }
});
```

---

## Rate Limiting

### Al-Quran Cloud API
- **No official rate limit**
- Be respectful: Don't make excessive requests
- Use caching for frequently accessed data

### Best Practices
```javascript
// Cache API responses
const cache = new Map();

async function fetchWithCache(url, ttl = 3600000) { // 1 hour TTL
  const cached = cache.get(url);
  
  if (cached && Date.now() - cached.timestamp < ttl) {
    return cached.data;
  }
  
  const response = await fetch(url);
  const data = await response.json();
  
  cache.set(url, {
    data: data,
    timestamp: Date.now()
  });
  
  return data;
}
```

---

## Best Practices

### 1. Caching Strategy
```javascript
// Use localStorage for persistent caching
class QuranCache {
  static set(key, data, expiryHours = 24) {
    const item = {
      data: data,
      expiry: Date.now() + (expiryHours * 3600000)
    };
    localStorage.setItem(`quran_${key}`, JSON.stringify(item));
  }
  
  static get(key) {
    const itemStr = localStorage.getItem(`quran_${key}`);
    if (!itemStr) return null;
    
    const item = JSON.parse(itemStr);
    if (Date.now() > item.expiry) {
      localStorage.removeItem(`quran_${key}`);
      return null;
    }
    
    return item.data;
  }
}

// Usage
async function getSurah(number) {
  const cacheKey = `surah_${number}`;
  let data = QuranCache.get(cacheKey);
  
  if (!data) {
    const response = await fetch(`https://api.alquran.cloud/v1/surah/${number}`);
    data = await response.json();
    QuranCache.set(cacheKey, data);
  }
  
  return data;
}
```

### 2. Progressive Loading
```javascript
// Load one surah at a time
async function loadSurahLazy(surahNumber) {
  const container = document.getElementById('ayahs');
  container.innerHTML = '<div class="loading">Loading...</div>';
  
  const data = await getSurah(surahNumber);
  
  // Render ayahs
  container.innerHTML = data.data.ayahs.map(ayah => `
    <div class="ayah">${ayah.text}</div>
  `).join('');
}
```

### 3. Preloading Audio
```javascript
// Preload next ayah audio
function preloadNextAudio(surah, ayah) {
  const nextAudio = new Audio();
  const surahStr = String(surah).padStart(3, '0');
  const ayahStr = String(ayah + 1).padStart(3, '0');
  nextAudio.src = `https://cdn.islamic.network/quran/audio/128/ar.alafasy/${surahStr}${ayahStr}.mp3`;
  nextAudio.preload = 'auto';
}
```

### 4. Offline Support with Service Worker
```javascript
// sw.js
const CACHE_NAME = 'quran-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/style.css',
  '/script.js'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => response || fetch(event.request))
  );
});
```

### 5. Retry Logic
```javascript
async function fetchWithRetry(url, retries = 3, delay = 1000) {
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url);
      if (response.ok) return response;
    } catch (error) {
      if (i === retries - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

---

## Complete Integration Example

```javascript
class QuranAPI {
  constructor() {
    this.baseUrl = 'https://api.alquran.cloud/v1';
    this.audioBaseUrl = 'https://cdn.islamic.network/quran/audio/128';
    this.cache = new Map();
  }
  
  async getSurah(number, edition = 'quran-uthmani') {
    const cacheKey = `surah_${number}_${edition}`;
    
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey);
    }
    
    const response = await fetch(`${this.baseUrl}/surah/${number}/${edition}`);
    const data = await response.json();
    
    this.cache.set(cacheKey, data.data);
    return data.data;
  }
  
  async getSurahWithTranslation(number, translation = 'en.sahih') {
    const response = await fetch(
      `${this.baseUrl}/surah/${number}/editions/quran-uthmani,${translation}`
    );
    const data = await response.json();
    
    return {
      arabic: data.data[0],
      translation: data.data[1]
    };
  }
  
  getAudioUrl(surah, ayah, reciter = 'ar.alafasy') {
    const surahStr = String(surah).padStart(3, '0');
    const ayahStr = String(ayah).padStart(3, '0');
    return `${this.audioBaseUrl}/${reciter}/${surahStr}${ayahStr}.mp3`;
  }
  
  async search(query, surah = 'all', edition = 'en.sahih') {
    const response = await fetch(
      `${this.baseUrl}/search/${query}/${surah}/${edition}`
    );
    const data = await response.json();
    return data.data.matches;
  }
}

// Usage
const quran = new QuranAPI();

// Get Surah Al-Fatihah with translation
quran.getSurahWithTranslation(1).then(data => {
  console.log('Arabic:', data.arabic);
  console.log('Translation:', data.translation);
});

// Get audio URL
const audioUrl = quran.getAudioUrl(1, 1, 'ar.alafasy');
console.log(audioUrl);

// Search for verses containing "paradise"
quran.search('paradise').then(results => {
  console.log('Found', results.length, 'verses');
});
```

---

## Resources

- **Al-Quran Cloud API Docs**: https://alquran.cloud/api
- **Islamic Network**: https://islamicnetwork.com
- **Quran.com API**: https://api-docs.quran.com
- **Tanzil Project**: http://tanzil.net/docs/

---

**May Allah accept this work and make it beneficial for the Ummah. Ameen.**