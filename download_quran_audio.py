#!/usr/bin/env python3
"""
Quran Audio Downloader
Downloads all 114 Surahs for multiple famous Quran reciters
Uses the Islamic.network API
"""

import os
import requests
import time
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

# Configure reciters and their API codes
RECITERS = {
    'alafasy': {
        'name': 'Mishary Rashid Alafasy',
        'api_code': 'ar.alafasy',
        'quality': '128'  # 64, 128, or 192 kbps
    },
    'sudais': {
        'name': 'Abdul Rahman Al-Sudais',
        'api_code': 'ar.abdulsamad',
        'quality': '128'
    },
    'minshawi': {
        'name': 'Mohamed El-Minshawi',
        'api_code': 'ar.minshawi',
        'quality': '128'
    },
    'ayub': {
        'name': 'Ahmed Al-Ajmi',
        'api_code': 'ar.ajmi',
        'quality': '128'
    },
    'jibril': {
        'name': 'Muhammad Jibril',
        'api_code': 'ar.ghamadi',
        'quality': '128'
    }
}

# Base directory for audio files
BASE_AUDIO_DIR = Path(__file__).parent / 'audio'

# Islamic.network API base URL
API_BASE_URL = 'https://cdn.islamic.network/quran/audio'

def create_directories():
    """Create necessary directories for all reciters"""
    for reciter_folder in RECITERS.keys():
        dir_path = BASE_AUDIO_DIR / reciter_folder
        dir_path.mkdir(parents=True, exist_ok=True)
        print(f"✓ Directory created/verified: {dir_path}")

def download_surah(reciter_folder, reciter_config, surah_number):
    """Download a single Surah and return status"""
    surah_str = str(surah_number).zfill(3)
    
    # Build URL: https://cdn.islamic.network/quran/audio/{quality}/{api_code}/{surah}001.mp3
    url = f"{API_BASE_URL}/{reciter_config['quality']}/{reciter_config['api_code']}/{surah_str}001.mp3"
    
    # Target file path
    file_path = BASE_AUDIO_DIR / reciter_folder / f"{surah_str}.mp3"
    
    try:
        # Download the file
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        
        # Write to file
        with open(file_path, 'wb') as f:
            f.write(response.content)
        
        file_size_mb = file_path.stat().st_size / (1024 * 1024)
        return {
            'status': 'success',
            'reciter': reciter_folder,
            'surah': surah_number,
            'size_mb': file_size_mb
        }
    
    except requests.exceptions.Timeout:
        return {
            'status': 'timeout',
            'reciter': reciter_folder,
            'surah': surah_number
        }
    except requests.exceptions.RequestException as e:
        return {
            'status': 'error',
            'reciter': reciter_folder,
            'surah': surah_number,
            'error': str(e)
        }
    except Exception as e:
        return {
            'status': 'error',
            'reciter': reciter_folder,
            'surah': surah_number,
            'error': str(e)
        }

def download_all_surahs(max_workers=5):
    """Download all Surahs for all reciters using parallel downloads"""
    
    print("\n" + "="*70)
    print("🎵 QURAN AUDIO DOWNLOADER")
    print("="*70)
    print(f"Total Surahs: 114")
    print(f"Total Reciters: {len(RECITERS)}")
    print(f"Total Files: {114 * len(RECITERS)}")
    print("="*70 + "\n")
    
    # Create directories
    create_directories()
    print()
    
    # Prepare download tasks
    tasks = []
    for reciter_folder, reciter_config in RECITERS.items():
        for surah in range(1, 115):
            tasks.append((reciter_folder, reciter_config, surah))
    
    print(f"Starting downloads with {max_workers} parallel threads...\n")
    
    # Track results
    results = {
        'success': 0,
        'error': 0,
        'timeout': 0,
        'total_size_mb': 0,
        'by_reciter': {r: {'success': 0, 'error': 0, 'timeout': 0} for r in RECITERS.keys()}
    }
    
    start_time = time.time()
    
    # Download using thread pool
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = [
            executor.submit(download_surah, reciter_folder, reciter_config, surah)
            for reciter_folder, reciter_config, surah in tasks
        ]
        
        completed = 0
        for future in as_completed(futures):
            completed += 1
            result = future.result()
            
            status = result['status']
            reciter = result['reciter']
            surah = result['surah']
            
            if status == 'success':
                results['success'] += 1
                results['by_reciter'][reciter]['success'] += 1
                results['total_size_mb'] += result['size_mb']
                print(f"[{completed}/{len(tasks)}] ✓ {reciter.upper()} - Surah {surah:3d} ({result['size_mb']:.2f} MB)")
            
            elif status == 'timeout':
                results['timeout'] += 1
                results['by_reciter'][reciter]['timeout'] += 1
                print(f"[{completed}/{len(tasks)}] ⏱ {reciter.upper()} - Surah {surah:3d} (TIMEOUT)")
            
            else:
                results['error'] += 1
                results['by_reciter'][reciter]['error'] += 1
                print(f"[{completed}/{len(tasks)}] ✗ {reciter.upper()} - Surah {surah:3d} (ERROR: {result.get('error', 'Unknown')})")
    
    elapsed_time = time.time() - start_time
    
    # Print summary
    print("\n" + "="*70)
    print("📊 DOWNLOAD SUMMARY")
    print("="*70)
    print(f"Total files downloaded: {results['success']}")
    print(f"Total errors: {results['error']}")
    print(f"Total timeouts: {results['timeout']}")
    print(f"Total size: {results['total_size_mb']:.2f} MB")
    print(f"Time elapsed: {elapsed_time:.1f} seconds")
    print("="*70)
    
    print("\nBreakdown by reciter:")
    for reciter in RECITERS.keys():
        stats = results['by_reciter'][reciter]
        total = stats['success'] + stats['error'] + stats['timeout']
        print(f"  {reciter.upper():12} - ✓ {stats['success']:3d}/114  ✗ {stats['error']:3d}  ⏱ {stats['timeout']:3d}")
    
    print("\n" + "="*70)
    
    # Return success count
    return results['success'] == len(tasks)

if __name__ == '__main__':
    try:
        success = download_all_surahs(max_workers=5)
        if success:
            print("\n✅ All downloads completed successfully!")
            print("Audio files are ready in the 'audio/' directory.")
            print("Next step: Push to GitHub with 'git push origin main'")
        else:
            print("\n⚠️  Some downloads failed. Check the log above for details.")
            print("You can retry failed downloads by running this script again.")
    
    except KeyboardInterrupt:
        print("\n\n⏹ Download interrupted by user.")
    except Exception as e:
        print(f"\n❌ Fatal error: {e}")
        import traceback
        traceback.print_exc()
