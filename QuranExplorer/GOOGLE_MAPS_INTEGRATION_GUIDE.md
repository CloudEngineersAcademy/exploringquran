# 🗺️ Google Maps API Integration Guide

## Setting Up Google Places API for Mosque Directory

### Overview
This guide explains how to integrate Google Maps Places API to fetch real mosque data, including locations, photos, reviews, and contact information.

---

## Step 1: Get Google Maps API Key

### Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Click "Create Project"
3. Name: "Quran Explorer Mosques"
4. Click "Create"

### Enable Required APIs
1. Navigate to "APIs & Services" → "Library"
2. Enable the following APIs:
   - **Maps JavaScript API**
   - **Places API**
   - **Geocoding API**
   - **Distance Matrix API** (optional)

### Create API Key
1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "API Key"
3. Copy your API key: `AIzaSy...`
4. Click "Restrict Key" (recommended)

### Restrict API Key
```
Application restrictions:
- HTTP referrers (websites)
- Add your domain: yoursite.com/*

API restrictions:
- Restrict key to:
  ✓ Maps JavaScript API
  ✓ Places API
  ✓ Geocoding API
```

---

## Step 2: Add Google Maps to HTML

### Update mosques.html
Replace the commented script tag at the bottom with:

```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places&callback=initMap" async defer></script>
```

**Replace `YOUR_API_KEY` with your actual API key**

---

## Step 3: Implement Google Places Search

### Complete JavaScript Implementation

Add this complete code to your `mosques.html`:

```javascript
let map;
let service;
let infowindow;
let markers = [];
let userLocation = null;

// Initialize Google Map
function initMap() {
    // Default location (London)
    const defaultLocation = { lat: 51.5074, lng: -0.1278 };
    
    map = new google.maps.Map(document.getElementById('map'), {
        center: defaultLocation,
        zoom: 12,
        styles: [
            {
                featureType: 'poi',
                elementType: 'labels',
                stylers: [{ visibility: 'off' }]
            }
        ]
    });

    infowindow = new google.maps.InfoWindow();
    
    // Try to get user's location
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            position => {
                userLocation = {
                    lat: position.coords.latitude,
                    lng: position.coords.longitude
                };
                map.setCenter(userLocation);
                
                // Add marker for user location
                new google.maps.Marker({
                    position: userLocation,
                    map: map,
                    icon: {
                        path: google.maps.SymbolPath.CIRCLE,
                        scale: 8,
                        fillColor: '#4285F4',
                        fillOpacity: 1,
                        strokeColor: '#fff',
                        strokeWeight: 2
                    },
                    title: 'Your Location'
                });
                
                // Search for nearby mosques
                searchNearbyMosques(userLocation);
            },
            () => {
                // Use default location if geolocation denied
                searchNearbyMosques(defaultLocation);
            }
        );
    } else {
        searchNearbyMosques(defaultLocation);
    }
}

// Search for nearby mosques
function searchNearbyMosques(location) {
    const request = {
        location: location,
        radius: 5000, // 5km radius
        type: ['mosque'],
        keyword: 'mosque OR masjid OR Islamic center OR musalla'
    };

    service = new google.maps.places.PlacesService(map);
    service.nearbySearch(request, handlePlacesResults);
}

// Handle search results
function handlePlacesResults(results, status) {
    if (status === google.maps.places.PlacesServiceStatus.OK) {
        // Clear existing markers
        markers.forEach(marker => marker.setMap(null));
        markers = [];
        
        // Process each result
        const mosquesArray = [];
        results.forEach((place, index) => {
            // Create marker
            const marker = new google.maps.Marker({
                position: place.geometry.location,
                map: map,
                title: place.name,
                icon: {
                    url: 'https://maps.google.com/mapfiles/kml/paddle/grn-circle.png',
                    scaledSize: new google.maps.Size(40, 40)
                }
            });
            
            markers.push(marker);
            
            // Add click listener to marker
            marker.addListener('click', () => {
                getPlaceDetails(place.place_id, marker);
            });
            
            // Get detailed information
            getPlaceDetailsForCard(place.place_id, index, mosquesArray);
        });
        
        // Update stats
        document.getElementById('totalMosques').textContent = results.length;
    } else {
        console.error('Places search failed:', status);
    }
}

// Get place details for marker popup
function getPlaceDetails(placeId, marker) {
    const request = {
        placeId: placeId,
        fields: ['name', 'formatted_address', 'formatted_phone_number', 
                 'website', 'rating', 'opening_hours', 'photos']
    };

    service.getDetails(request, (place, status) => {
        if (status === google.maps.places.PlacesServiceStatus.OK) {
            const content = `
                <div style="max-width: 300px;">
                    <h3 style="margin: 0 0 10px 0; color: #2c5f2d;">${place.name}</h3>
                    ${place.photos ? `<img src="${place.photos[0].getUrl({maxWidth: 300})}" style="width: 100%; border-radius: 8px; margin-bottom: 10px;">` : ''}
                    <p style="margin: 5px 0;"><strong>Address:</strong> ${place.formatted_address}</p>
                    ${place.formatted_phone_number ? `<p style="margin: 5px 0;"><strong>Phone:</strong> ${place.formatted_phone_number}</p>` : ''}
                    ${place.rating ? `<p style="margin: 5px 0;"><strong>Rating:</strong> ⭐ ${place.rating}</p>` : ''}
                    ${place.website ? `<p style="margin: 10px 0 0 0;"><a href="${place.website}" target="_blank" style="color: #2c5f2d;">Visit Website</a></p>` : ''}
                </div>
            `;
            infowindow.setContent(content);
            infowindow.open(map, marker);
        }
    });
}

// Get detailed place information for cards
function getPlaceDetailsForCard(placeId, index, mosquesArray) {
    const request = {
        placeId: placeId,
        fields: ['name', 'formatted_address', 'formatted_phone_number', 
                 'international_phone_number', 'website', 'rating', 
                 'user_ratings_total', 'opening_hours', 'photos', 
                 'geometry', 'types', 'reviews']
    };

    service.getDetails(request, (place, status) => {
        if (status === google.maps.places.PlacesServiceStatus.OK) {
            const mosqueData = {
                id: index + 1,
                name: place.name,
                arabicName: "", // Would need separate API for Arabic names
                type: place.types.includes('mosque') ? 'Masjid' : 'Islamic Center',
                address: place.formatted_address,
                phone: place.formatted_phone_number || place.international_phone_number || 'N/A',
                email: 'N/A', // Not provided by Google Places
                website: place.website || '#',
                image: place.photos && place.photos[0] ? place.photos[0].getUrl({maxWidth: 800}) : 'https://via.placeholder.com/800x500/2c5f2d/ffffff?text=' + encodeURIComponent(place.name),
                rating: place.rating || 0,
                reviews: place.user_ratings_total || 0,
                distance: userLocation ? calculateDistance(userLocation, place.geometry.location) : 'N/A',
                verified: place.user_ratings_total > 50,
                features: extractFeatures(place),
                prayerTimes: {
                    Fajr: "Check locally",
                    Dhuhr: "Check locally",
                    Asr: "Check locally",
                    Maghrib: "Check locally",
                    Isha: "Check locally"
                },
                social: {
                    facebook: '',
                    twitter: '',
                    instagram: '',
                    youtube: ''
                },
                openingHours: place.opening_hours
            };
            
            mosquesArray.push(mosqueData);
            
            // Render when we have all results
            if (mosquesArray.length === index + 1) {
                loadMosques(mosquesArray.sort((a, b) => 
                    parseFloat(a.distance) - parseFloat(b.distance)
                ));
            }
        }
    });
}

// Calculate distance between two points
function calculateDistance(point1, point2) {
    const lat1 = point1.lat;
    const lon1 = point1.lng;
    const lat2 = point2.lat();
    const lon2 = point2.lng();
    
    const R = 6371; // Earth's radius in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLon/2) * Math.sin(dLon/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    const distance = R * c;
    
    return distance.toFixed(1) + ' km';
}

// Extract features from place data
function extractFeatures(place) {
    const features = [];
    
    if (place.opening_hours && place.opening_hours.isOpen()) {
        features.push('Open Now');
    }
    
    // Default mosque features
    features.push('Wudu', 'Prayer Space');
    
    if (place.user_ratings_total > 100) {
        features.push('Popular');
    }
    
    return features;
}

// Update search location function
function searchLocation() {
    const location = document.getElementById('locationInput').value;
    if (location.trim()) {
        const geocoder = new google.maps.Geocoder();
        geocoder.geocode({ address: location }, (results, status) => {
            if (status === 'OK') {
                const location = results[0].geometry.location;
                map.setCenter(location);
                searchNearbyMosques(location);
            } else {
                alert('Location not found. Please try again.');
            }
        });
    } else {
        alert('Please enter a location');
    }
}

// Update use current location function
function useCurrentLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            position => {
                userLocation = {
                    lat: position.coords.latitude,
                    lng: position.coords.longitude
                };
                map.setCenter(userLocation);
                searchNearbyMosques(userLocation);
            },
            error => {
                alert('Unable to get your location. Please enter manually.');
            }
        );
    } else {
        alert('Geolocation is not supported by your browser');
    }
}
```

---

## Step 4: Integrate Prayer Times API

### Use Aladhan Prayer Times API

Add this function to get accurate prayer times:

```javascript
async function getPrayerTimes(latitude, longitude) {
    try {
        const date = new Date();
        const response = await fetch(
            `https://api.aladhan.com/v1/timings/${date.getTime()/1000}?latitude=${latitude}&longitude=${longitude}&method=2`
        );
        const data = await response.json();
        
        if (data.code === 200) {
            return {
                Fajr: data.data.timings.Fajr,
                Dhuhr: data.data.timings.Dhuhr,
                Asr: data.data.timings.Asr,
                Maghrib: data.data.timings.Maghrib,
                Isha: data.data.timings.Isha
            };
        }
    } catch (error) {
        console.error('Error fetching prayer times:', error);
        return null;
    }
}

// Update prayer times for each mosque
async function updatePrayerTimes(mosqueData) {
    for (let mosque of mosqueData) {
        const times = await getPrayerTimes(mosque.lat, mosque.lng);
        if (times) {
            mosque.prayerTimes = times;
        }
    }
}
```

---

## Step 5: Cost Optimization

### Free Tier Limits (as of 2024)
- **Maps JavaScript API**: $200 free credit/month
- **Places API**: First $200 free
- **Requests**: ~28,000 map loads/month free
- **Places Nearby**: ~5,000 requests/month free

### Optimization Tips

#### 1. Cache Results
```javascript
// Cache mosque data in localStorage
function cacheMosqueData(location, data) {
    const cacheKey = `mosques_${location.lat}_${location.lng}`;
    const cacheData = {
        data: data,
        timestamp: Date.now()
    };
    localStorage.setItem(cacheKey, JSON.stringify(cacheData));
}

function getCachedMosqueData(location) {
    const cacheKey = `mosques_${location.lat}_${location.lng}`;
    const cached = localStorage.getItem(cacheKey);
    
    if (cached) {
        const cacheData = JSON.parse(cached);
        const age = Date.now() - cacheData.timestamp;
        
        // Cache valid for 24 hours
        if (age < 24 * 60 * 60 * 1000) {
            return cacheData.data;
        }
    }
    
    return null;
}
```

#### 2. Lazy Load Map
```javascript
// Only load map when user scrolls to it
const mapObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            initMap();
            mapObserver.disconnect();
        }
    });
});

mapObserver.observe(document.getElementById('map'));
```

#### 3. Reduce API Calls
```javascript
// Debounce search function
let searchTimeout;
function debouncedSearch() {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
        searchLocation();
    }, 500);
}
```

---

## Step 6: Alternative Free Options

### Option 1: OpenStreetMap + Overpass API
Free alternative to Google Maps

```javascript
// Using Leaflet.js + OpenStreetMap
function initOSMMap() {
    const map = L.map('map').setView([51.505, -0.09], 13);
    
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);
    
    // Search for mosques using Overpass API
    const query = `
        [out:json];
        (
          node["amenity"="place_of_worship"]["religion"="muslim"](around:5000,${lat},${lng});
          way["amenity"="place_of_worship"]["religion"="muslim"](around:5000,${lat},${lng});
        );
        out body;
    `;
    
    fetch(`https://overpass-api.de/api/interpreter?data=${encodeURIComponent(query)}`)
        .then(response => response.json())
        .then(data => {
            // Process and display mosques
            data.elements.forEach(mosque => {
                L.marker([mosque.lat, mosque.lon])
                    .bindPopup(mosque.tags.name || 'Mosque')
                    .addTo(map);
            });
        });
}
```

### Option 2: Mapbox
More affordable than Google Maps

```javascript
// Using Mapbox GL JS
mapboxgl.accessToken = 'YOUR_MAPBOX_TOKEN';
const map = new mapboxgl.Map({
    container: 'map',
    style: 'mapbox://styles/mapbox/streets-v11',
    center: [-0.1278, 51.5074],
    zoom: 12
});
```

---

## Step 7: Testing

### Test Your Implementation

```javascript
// Test with console logs
console.log('Map initialized:', map);
console.log('Service initialized:', service);
console.log('Mosques found:', mosquesData.length);

// Test API connection
async function testGooglePlacesAPI() {
    const testLocation = { lat: 51.5074, lng: -0.1278 };
    const request = {
        location: testLocation,
        radius: 1000,
        type: ['mosque']
    };
    
    service.nearbySearch(request, (results, status) => {
        console.log('API Status:', status);
        console.log('Results:', results);
    });
}
```

---

## Step 8: Deploy to Production

### Environment Variables
Never expose API keys in client-side code!

**Option 1: Backend Proxy**
Create a Node.js proxy:

```javascript
// server.js
const express = require('express');
const axios = require('axios');
const app = express();

app.get('/api/mosques', async (req, res) => {
    const { lat, lng } = req.query;
    const apiKey = process.env.GOOGLE_MAPS_API_KEY;
    
    const response = await axios.get(
        `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lat},${lng}&radius=5000&type=mosque&key=${apiKey}`
    );
    
    res.json(response.data);
});

app.listen(3000);
```

**Option 2: Netlify Functions**
```javascript
// netlify/functions/mosques.js
exports.handler = async (event) => {
    const { lat, lng } = event.queryStringParameters;
    const apiKey = process.env.GOOGLE_MAPS_API_KEY;
    
    // Make API request
    const response = await fetch(/* ... */);
    
    return {
        statusCode: 200,
        body: JSON.stringify(data)
    };
};
```

---

## Troubleshooting

### Common Issues

**1. API Key not working**
- Check API is enabled in Cloud Console
- Verify domain restrictions
- Check billing is enabled

**2. No results returned**
- Check console for errors
- Verify location coordinates
- Increase search radius

**3. Map not loading**
- Check API key is correct
- Verify script src URL
- Check for JavaScript errors

**4. Photos not displaying**
- Photos require valid API key
- Check photo reference validity
- Use placeholder if unavailable

---

## Best Practices

1. **Always restrict API keys** to your domain
2. **Cache results** to reduce API calls
3. **Handle errors** gracefully
4. **Provide fallback** data
5. **Test thoroughly** before deployment
6. **Monitor usage** in Google Cloud Console
7. **Set up billing alerts** to avoid surprises

---

## Resources

- [Google Maps Platform](https://developers.google.com/maps)
- [Places API Documentation](https://developers.google.com/maps/documentation/places/web-service)
- [Prayer Times API (Aladhan)](https://aladhan.com/prayer-times-api)
- [OpenStreetMap](https://www.openstreetmap.org)
- [Leaflet.js](https://leafletjs.com)

---

**Cost Estimate:**
- Small site (<10K visits/month): **FREE**
- Medium site (10K-50K visits/month): **$50-150/month**
- Large site (50K+ visits/month): **Contact for pricing**

*Last updated: March 2026*