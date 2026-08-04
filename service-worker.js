// Bump this when any precached file changes so clients pick up the update.
const CACHE_VERSION = "v2";
const CACHE_NAME = "daimoku-" + CACHE_VERSION;

const PRECACHE_URLS = [
  "./",
  "./index.html",
  "./manifest.json",
  "./support.js",
  "./_ds/organic-5c9169ed-8b8c-4e8d-b745-3c835b559fd7/styles.css",
  "./_ds/organic-5c9169ed-8b8c-4e8d-b745-3c835b559fd7/_ds_bundle.js",
  "./_ds/organic-5c9169ed-8b8c-4e8d-b745-3c835b559fd7/fonts/caprasimo-400.woff2",
  "./_ds/organic-5c9169ed-8b8c-4e8d-b745-3c835b559fd7/fonts/figtree-variable.woff2",
  "./vendor/react.production.min.js",
  "./vendor/react-dom.production.min.js",
  "./icons/icon-192.png",
  "./icons/icon-512.png",
  "./icons/apple-touch-icon.png"
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(PRECACHE_URLS))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((names) => Promise.all(
        names.filter((n) => n !== CACHE_NAME).map((n) => caches.delete(n))
      ))
      .then(() => self.clients.claim())
  );
});

// Cache-first for everything we precached (the whole app shell is static);
// network-first with a cache fallback for anything else, so the app still
// opens with no connection once it's been loaded successfully once.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") return;

  event.respondWith(
    caches.match(event.request).then((cached) => {
      if (cached) return cached;
      return fetch(event.request)
        .then((response) => {
          if (response && response.ok) {
            const copy = response.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy));
          }
          return response;
        })
        .catch(() => caches.match("./index.html"));
    })
  );
});
