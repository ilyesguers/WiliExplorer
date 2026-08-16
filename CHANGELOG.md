# Changelog

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
