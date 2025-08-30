# SellBetter — MVP Project Plan

> Goal: Ship a cross‑platform MVP that lets users upload product photos, run them through fal.ai (Gemini 2.5 Flash Image / “nano‑banana”) for trustworthy, high‑quality polishing, preview via before/after slider, and export for Craigslist/Marketplace listings.

---

## 1) Product Scope (MVP)

**Must‑have**

- Upload 1–5 photos (camera or gallery)
- Call fal.ai to run a single, safe “polish” pipeline (background cleanup, relight, clutter removal, contact shadow)
- Before/After slider per photo
- Export (Save to device / Share sheet)
- Lightweight transparency: “AI‑edited” badge toggle + link to “What changed?”
- Anonymous usage counter (session + processed image count)

**Nice‑to‑have (stretch)**

- Category selection (Furniture / Shoes / Electronics / Cars)
- Batch processing UI
- History (local device cache)
- Simple onboarding screen with 10‑second demo

**Out of scope (MVP)**

- Accounts/logins, payments, cloud libraries, pro tiers
- Chrome extension, in‑marketplace integrations
- Heavy image management (albums, tags)

---

## 2) Target Platforms & Rationale

- **Flutter (iOS, Android, Web)** — single codebase, strong image UI perf, mature plugins for camera, share sheet, file picker.
- **Fallback**: If Flutter Web perf is insufficient for large images, keep web as a static landing/demo that links to mobile stores.

---

## 3) Architecture Overview

**Client** (Flutter) ↔ **API Proxy** (optional, Cloud Functions) ↔ **fal.ai** (Gemini Image Editing)

- For true MVP speed, the app can call fal.ai directly with a short‑lived token fetched from a minimal proxy (prevents exposing static API keys).
- Use deterministic image ops locally (crop/resize/format) and reserve model calls for semantic edits.

**Data flows**

1. User selects photo(s) → local pre‑processing (orientation fix, resize if huge).
2. Send to fal.ai with prompt template → receive polished image.
3. Render Before/After → export.
4. Log an anonymous event (count only) to proxy for metrics.

---

## 4) Tech Stack & Key Packages

- **Flutter**: `image_picker`, `camera`, `photo_view` (pinch/zoom), `share_plus`, `path_provider`, `path`, `http`, `flutter_riverpod` (state), `go_router` (nav), `transparent_image` (placeholder), `dio` (optional, retries), `flutter_cache_manager`.
- **Local image ops**: `image` (Dart package) or native platform channels if needed.
- **Backend (optional)**: Firebase Cloud Functions / Supabase Edge Functions for token minting + event logging.
- **Analytics**: PostHog/Amplitude (anonymous user + events), or a minimal endpoint storing counts in Postgres/Firestore.

---

## 5) Security & Privacy (MVP‑level)

- Never store user photos on server; process, return, and discard. Keep **originals** and **edits** only on device unless user opts into cloud history later.
- Proxy mints a **short‑lived access token** for fal.ai (e.g., JWT valid for 10–30 minutes). No hard‑coded API keys in app bundle.
- Strip EXIF GPS metadata on export.
- Provide a visible **AI‑edited** label toggle and “What changed?” sheet (we will show an edit manifest and encourage keeping the label on).

---

## 6) API Surface (fal.ai via proxy)

**Proxy endpoints (minimal)**

- `POST /v1/token` → returns a short‑lived token for fal.ai
- `POST /v1/metrics` → `{ event: 'polish_completed', count: n, platform, category? }`

**fal.ai call (conceptual)**

- Endpoint: `POST https://fal.run/.../gemini-image-edit` (placeholder; supply actual runtime path)
- Headers: `Authorization: Bearer <short_lived_token>`
- Body (multipart or JSON+base64):

```json
{
  "prompt": "Polish this product photo for an online listing. Preserve product geometry, textures, and markings. Clean background to a neutral light gray, correct lighting, add a soft realistic contact shadow, and remove clutter not part of the product. Do not invent features.",
  "image": "<base64 or URL>",
  "variants": 1,
  "size": "original"
}
```

- Response: `{ image_url | base64, safety: {...}, cost: {...} }`

> Note: Keep the prompt short, explicit on scope, and idempotent. Avoid specifying aspect ratio/crop in the prompt—do that locally for determinism.

---

## 7) Prompt Templates (v1 + category variants)

**Base (default)**

```
Goal: make this product photo listing‑ready without deception.
• Preserve product geometry, textures, brand markings.
• Replace background with a neutral light gray (studio sweep).
• Correct lighting/white balance; reduce glare; keep true color.
• Remove objects not part of the product (hands, clutter, cables).
• Add a soft, physically plausible contact shadow.
• Do NOT invent accessories or change the product’s shape.
```

**Furniture**

```
As Base, plus:
• Correct perspective so verticals are vertical; eye‑level feel.
• Retain wood grain/fabric texture; subtle finish sheen.
```

**Shoes/Clothing**

```
As Base, plus:
• Remove lint/loose threads; keep natural creasing.
• Slight edge contrast for outlines; avoid plastic look.
```

**Electronics**

```
As Base, plus:
• Reduce screen glare while keeping screen readable.
• No invented ports/buttons; remove fingerprints.
```

**Cars**

```
As Base, plus:
• Even daylight; reduce harsh reflections; keep paint texture.
• Remove license plate text; keep blank placeholder plate.
```

---

## 8) Flutter App Structure

**Navigation (go\_router)**

- `/` → `LandingScreen`
- `/picker` → `PickerScreen`
- `/process` → `ProcessingScreen`
- `/result` → `ResultScreen`
- `/about` → `AboutScreen` (AI transparency)

**State (Riverpod)**

- `photosProvider` (List)
- `processingProvider` (Async state of current job)
- `settingsProvider` (category, watermark toggle)

**Key Widgets**

- `PhotoTile` (thumbnail + status)
- `BeforeAfterSlider` (custom painter overlay; draggable handle)
- `ActionBar` (Download, Share, Polish Again)

**Flow**

1. Landing: CTA → “Polish your listing photos”
2. Picker: select 1–5 images → confirm category (optional)
3. Processing: upload → fal.ai call → progress → result
4. Result: slider + actions; “What changed?” sheet (bullets)

---

## 9) Image Handling & Performance

- Cap input resolution to \~3072 px long edge for speed; retain original locally.
- Export defaults: JPG or WebP, sRGB, long edge 1536 px (marketplace‑friendly), quality 85–90; file size target < 1.5 MB.
- Deterministic crops: 1:1 (square) and 4:3 variants via local processing.
- Memory safety: process one photo at a time if device is low‑RAM; allow queue.

---

## 10) Telemetry & Metrics (MVP)

- Anonymous device id (UUID v4 stored locally)
- Counters: `polish_started`, `polish_succeeded`, `polish_failed`
- Avg processing time, failure codes, platform (iOS/Android/Web)
- Optional: category usage distribution

---

## 11) Error Handling & UX Fallbacks

- Network fail → offer retry; keep job in queue
- fal.ai error → show readable message + “Send debug report”
- Image too small/large → advise user; auto‑resize
- Incomplete result → display original and offer re‑run

---

## 12) QA Checklist

- Visual sanity: no invented features; edges not melted; color truthfulness
- Compare SSIM/LPIPS against original to flag extreme changes
- Manual audit: 50 photos across 5 categories; annotate issues
- Accessibility: slider handle reachable; large tap targets; VoiceOver labels

---

## 13) Legal & Trust (MVP)

- In‑app disclosure: “Edited with AI (polish only, no feature invention).”
- Keep original on device; do not upload to server without consent
- EXIF GPS stripped on export
- Prepare marketplace compliance note (e.g., “Images edited for clarity; product unchanged”)

---

## 14) Milestones & Deliverables

**Milestone A — App Skeleton**

- Routing + screens + state
- Photo picker & thumbnail grid

**Milestone B — fal.ai Integration**

- Proxy token endpoint
- Single image polish call (base prompt)
- Progress + result rendering

**Milestone C — UX Polish**

- Before/After slider
- Export (save/share) + watermark overlay (free tier)
- About/Transparency page

**Milestone D — Launch Pack**

- Landing site (one‑pager with demo GIF)
- Android open testing build + Flutter web demo
- Feedback form (Tally/Typeform) + PostHog/Amplitude wired

---

## 15) Risks & Mitigations

- **API key exposure** → short‑lived token via proxy
- **Model over‑editing** → tight prompt, post‑diff checks, user re‑run
- **Large image memory crashes** → pre‑resize, sequential processing
- **Marketplace distrust** → explicit disclosure + before/after slider

---

## 16) Future (post‑MVP)

- Batch processing (5–10 photos at once)
- Category‑specific chains (cars/furniture/shoes/electronics)
- Chrome extension (Craigslist/FB upload interception)
- Paywall: HD, watermark removal, batch; Stripe mobile SDK
- Cloud history + cross‑device sync
- A/B testing: listing CTR, message rate, time‑to‑sale (partner pilot)

---

## 17) AI‑Agent Handoff Notes

- Keep prompts as JSON constants in `/lib/prompts/` for fast iteration
- Implement `FalService` with a single `polishImage()` method (pure function signature) so the agent can stub/mockingbird test easily
- Use feature flags via a local JSON (`/assets/flags.json`) to toggle category variants and watermarking without code changes
- Provide a `DEV_NOTES.md` explaining how to run web and mobile builds, where to set proxy base URL, and how to capture logs

---

### File/Folder Scaffold (proposed)

```
lib/
  main.dart
  app.dart
  routes.dart
  screens/
    landing_screen.dart
    picker_screen.dart
    processing_screen.dart
    result_screen.dart
    about_screen.dart
  widgets/
    before_after_slider.dart
    photo_tile.dart
    action_bar.dart
  state/
    providers.dart
    models.dart
  services/
    fal_service.dart
    image_utils.dart
    storage.dart
  prompts/
    base.json
    furniture.json
    shoes.json
    electronics.json
    cars.json
assets/
  flags.json
```

---

**Definition of Done (MVP)**

- End‑to‑end on device: pick → polish (fal.ai) → slider → export
- Works on Android + iOS (TestFlight later), optional Flutter Web demo
- Anonymous metrics show ≥ 100 completed polishes in the wild
- Basic landing site live with demo and download links

