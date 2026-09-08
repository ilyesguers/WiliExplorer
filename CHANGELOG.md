# Changelog

## 7.0.0 — Universal Viewer & UI Life

### العارض الشامل (Universal File Viewer)
- Rewrote `FileViewer` as one viewer for **every** instance type — no more info-only screens:
  - Scripts: full syntax-highlighted code (Highlighter) with edit / save / run / copy.
  - Sounds: embedded player (play, pause, stop, loop, volume, speed, pitch) + full editor link.
  - Images: large checkerboard preview + editor link + ID copy.
  - VideoFrames: real video preview with reload and loop controls.
  - Models / parts / meshes: 3D `ViewportFrame` preview with bounding-box camera, auto-rotate and reset.
  - Animations: length/keyframe metadata and play-on-your-character support.
  - GUI: scaled interactive clone preview with zoom control.
  - Effects: live viewport demo with animated demo part and enable toggle.
  - Lights: color swatch, brightness/range/angle sliders, shadow toggle.
  - Values: inline editors (string/number/bool toggle/Color3/BrickColor/ObjectValue).
  - Remotes: type info, fire/invoke, live listener count.
  - Everything else: rich info + editable **Properties tab** + attributes + tags + navigable children.
- Every preview registers a cleanup routine (heartbeats, sounds, tracks, clones) run on close.

### واجهة حية وأزرار مضبوطة
- MainFrame top bar rebuilt with an automatic `UIListLayout` control cluster — no more overlapping hard-coded button positions.
- Unified tooltips, icon labels separated from text, hover/press states on every control.
- Language/DEV/Login buttons now keep icons in their own labels (RTL-safe).
- Sidebar entrance animations (staggered fade/slide) — `Animations` module is now actually loaded and used.
- FileViewer window entrance animation and animated tab switching.

### شجرة أقوى
- TreeView v3: 13 category filters covering every `FileScanner` category, sort by name/type,
  long-press context menu (copy name/path/class, clone, delete, view), per-row open button,
  translated strings, hover/press life on rows and search results.

### إصلاحات
- `Theme/Assets.Apply` rewritten from a one-line obfuscated statement.
- Viewer refuses to clone `DataModel`/`game`/`workspace` and caps previews at 800 descendants.
- All preview clones pass through `StripScripts` (scripts removed, sounds silenced).
- Code text stays LTR inside the Arabic UI.
- `PropertyEditor` and `Animations` added to `Config.Modules` (previously never loaded).

### أدوات المطوّر
- New `tools/check-lua-strict.js`: real Lua 5.3 parse via fengari, run by `npm run check`.
- `Icons` registry v2: icon for every class name + UI glyphs + icon-separation helpers.
- New `docs/ARCHITECTURE_AR.md`: full file map, dependency graph, flaws found and fixed.

## 6.1.0 — Developer Console

### Explorer integration follow-up
- Removed every independent `HttpGet` module download from the explorer UI; dependencies now come only from the Loader registry.
- Rebuilt Sidebar with automatic layouts, direct-child counts, one analysis entry point, unified theme colors, and guarded navigation.
- Added complete-tree batched search without reading script source during tree rendering.
- Added shared `UIHelpers` and an administrator-managed `Theme/Assets` manifest with repository artwork workflow.
- Removed deprecated `spawn`, `wait`, `RunContext`, and manual UI signal firing patterns from the affected paths.
- Removed legacy SmartMenu, AdvancedUI, AdvancedTools, Keys, and AntiTamper files from the production source tree.
- Collapsed the Core analyzer UI entry point into the single AnalyzerUI implementation.

### Added
- Responsive, bilingual Developer Console replacing the legacy Klimbo menu.
- Batched cancellable inspector with search, type filters, progress, and hard limits.
- Low-frequency performance dashboard for FPS, memory, latency, and session time.
- Power saver, motion, scan batch, and object limit controls with touch sliders.
- Central logger and lifecycle cleanup utilities.
- Cached config-driven loader and module load report.
- Backend-oriented key verification with expiry validation and explicit device capability.
- Lua syntax CI, deterministic build manifest, and repository ignore rules.

### Changed
- Removed all third-party script hub entries and repeat downloads from the Developer Console.
- Removed legacy metatable hooks, RemoteSpy, AntiKick, aimbot, ESP, and client-only actions presented as server features from Klimbo.
- Game scans now traverse incrementally instead of allocating full descendant arrays.
- Save writes are debounced and auto-save can be stopped cleanly.
- File sorting caches expensive metadata per item.
- Arabic now has a reusable RTL application helper.

### Fixed
- Undefined `Mouse` and `ScriptScanner_GetEditable` Klimbo failures by replacing the legacy implementation.
- Unprotected Marketplace product lookups.
- Blocking/inaccurate FPS sampling.
- invalid attempts to call `RBXScriptSignal:Fire()`.
- global GameAnalyzer frozen-value state leakage.
