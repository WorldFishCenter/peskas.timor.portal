// Service Worker for Peskas Dashboard
// Provides advanced caching for static assets and API responses

const CACHE_NAME = 'peskas-dashboard-v1';
const STATIC_CACHE_URLS = [
  '/',
  '/favicon.ico',
  // Add other static assets as needed
];

const API_CACHE_DURATION = 5 * 60 * 1000; // 5 minutes
const STATIC_CACHE_DURATION = 24 * 60 * 60 * 1000; // 24 hours

// Install event - cache static assets
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('SW: Caching static assets');
        return cache.addAll(STATIC_CACHE_URLS);
      })
      .then(() => {
        console.log('SW: Installation complete');
        return self.skipWaiting();
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('SW: Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      console.log('SW: Activation complete');
      return self.clients.claim();
    })
  );
});

// Fetch event - implement caching strategies
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  
  // Skip non-GET requests
  if (event.request.method !== 'GET') {
    return;
  }
  
  // Skip Shiny WebSocket connections
  if (url.pathname.includes('websocket') || url.pathname.includes('__sockjs__')) {
    return;
  }
  
  // Cache strategy for static assets
  if (isStaticAsset(url)) {
    event.respondWith(cacheFirstStrategy(event.request));
    return;
  }
  
  // Cache strategy for API calls (if any)
  if (isApiCall(url)) {
    event.respondWith(networkFirstStrategy(event.request));
    return;
  }
  
  // Default: try network first, fallback to cache
  event.respondWith(networkFirstStrategy(event.request));
});

// Helper functions
function isStaticAsset(url) {
  const staticExtensions = ['.js', '.css', '.png', '.jpg', '.jpeg', '.gif', '.svg', '.ico', '.woff', '.woff2'];
  return staticExtensions.some(ext => url.pathname.endsWith(ext)) ||
         url.hostname.includes('cdn.jsdelivr.net') ||
         url.hostname.includes('code.jquery.com');
}

function isApiCall(url) {
  return url.pathname.includes('/api/') || url.pathname.includes('/data/');
}

// Cache-first strategy (for static assets)
async function cacheFirstStrategy(request) {
  try {
    const cachedResponse = await caches.match(request);
    if (cachedResponse) {
      // Check if cached response is still valid
      const cacheTime = cachedResponse.headers.get('sw-cache-time');
      if (cacheTime && Date.now() - parseInt(cacheTime) < STATIC_CACHE_DURATION) {
        return cachedResponse;
      }
    }
    
    // Fetch from network and update cache
    const networkResponse = await fetch(request);
    if (networkResponse.ok) {
      const cache = await caches.open(CACHE_NAME);
      const responseToCache = networkResponse.clone();
      responseToCache.headers.set('sw-cache-time', Date.now().toString());
      cache.put(request, responseToCache);
    }
    
    return networkResponse;
  } catch (error) {
    console.log('SW: Cache-first failed, trying cache:', error);
    return caches.match(request);
  }
}

// Network-first strategy (for dynamic content)
async function networkFirstStrategy(request) {
  try {
    const networkResponse = await fetch(request);
    
    if (networkResponse.ok) {
      // Cache successful responses
      const cache = await caches.open(CACHE_NAME);
      const responseToCache = networkResponse.clone();
      responseToCache.headers.set('sw-cache-time', Date.now().toString());
      cache.put(request, responseToCache);
    }
    
    return networkResponse;
  } catch (error) {
    console.log('SW: Network failed, trying cache:', error);
    
    // Try to serve from cache
    const cachedResponse = await caches.match(request);
    if (cachedResponse) {
      // Add a header to indicate this is from cache
      const response = cachedResponse.clone();
      response.headers.set('sw-from-cache', 'true');
      return response;
    }
    
    // Return a fallback response for critical failures
    return new Response('Offline - Content unavailable', {
      status: 503,
      statusText: 'Service Unavailable',
      headers: {
        'Content-Type': 'text/plain'
      }
    });
  }
}

// Message handling for cache management
self.addEventListener('message', event => {
  if (event.data && event.data.type) {
    switch (event.data.type) {
      case 'CLEAR_CACHE':
        caches.delete(CACHE_NAME).then(() => {
          event.ports[0].postMessage({ success: true });
        });
        break;
        
      case 'CACHE_STATUS':
        caches.open(CACHE_NAME).then(cache => {
          return cache.keys();
        }).then(keys => {
          event.ports[0].postMessage({ 
            cacheSize: keys.length,
            cacheName: CACHE_NAME 
          });
        });
        break;
        
      default:
        console.log('SW: Unknown message type:', event.data.type);
    }
  }
});

console.log('SW: Service Worker loaded');