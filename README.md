# Daimoku Practice Tracker

A daily Daimoku practice tracker: log session minutes, watch your streak and a
"practice tree" that grows or wilts with consistency, and set daily/weekly/streak
goals. Installable as a PWA — works offline once loaded, no account or server needed.

Data lives entirely in the browser's `localStorage` on whatever device you install it
on (single-device, no sync). Login/register is a lightweight local check, not a real
auth system — it just keeps separate people's data apart in the same browser.

## Local testing

Opening `index.html` directly (`file://`) won't let the service worker register —
browsers only allow that over `http(s)://`. Serve it locally first:

```bash
powershell -ExecutionPolicy Bypass -File scripts/serve.ps1
```

Then open `http://localhost:8080/` in a browser. To confirm it's really installable,
check DevTools → Application → Manifest and → Service Workers (should show
"activated and is running"), then try reloading with the network throttled to
"Offline" — the app should still load.

## Deploying to GitHub Pages

1. Create a new empty repository on GitHub (no README/license — this folder already
   has its own git history).
2. From this folder:
   ```bash
   git remote add origin https://github.com/<you>/<repo>.git
   git branch -M main
   git push -u origin main
   ```
3. In the repo on GitHub: **Settings → Pages → Source → Deploy from a branch**, pick
   `main` and `/ (root)`, then save. GitHub gives you a URL like
   `https://<you>.github.io/<repo>/` a minute or two later.
4. Open that URL on a phone and use the browser's "Add to Home Screen" (Android
   Chrome) or share-sheet "Add to Home Screen" (iOS Safari) to install it.

## Project layout

- `index.html` — deploy entry point (what GitHub Pages serves at `/`)
- `Daimoku Practice Tracker.dc.html` — same app; kept in sync with `index.html` so it
  can still be opened/edited via [claude.ai/design](https://claude.ai/design). If you
  edit it there and sync changes back down, re-apply the `<head>` additions (manifest
  link, service worker registration, the `window.__resources` override) since the
  Design tool only owns the `<x-dc>` template body, not this wrapper.
- `support.js` — generated app runtime, do not edit by hand
- `manifest.json`, `service-worker.js` — PWA install/offline support
- `vendor/` — self-hosted React/ReactDOM (avoids depending on unpkg.com at runtime)
- `_ds/organic-.../` — the "Organic" design system (tokens, component CSS, fonts)
- `scripts/serve.ps1` — local static server for testing (see above)
- `scripts/generate-icons.ps1` — regenerates `icons/*.png` if you want to redesign
  the app icon
