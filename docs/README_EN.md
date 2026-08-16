# WiliExplorer 6.1 Guide

## Quick start
1. Open Explorer and select a service.
2. Search by item name, class, or full path.
3. Use filter chips to focus on scripts, models, images, sounds, or values.
4. Select an item to open its type-specific preview and tools.

## New Developer Console
The `DEV` button opens a self-contained workspace with no third-party scripts:

- **Overview:** experience identity and latest scan totals.
- **Inspect:** cancellable incremental scanning, search, filters, and memory limits.
- **Performance:** FPS, memory, latency, and session uptime.
- **Settings:** power saver, motion, batch size, and object limit.

Inspection is local and read-only for network endpoints. The console does not fire remotes or install metatable hooks, and it no longer presents client-only effects as server actions.

## Mobile
- Rotation recalculates layouts automatically.
- New controls use touch-friendly targets around 44px or larger.
- Tab and filter rows scroll horizontally.
- Image, sound, and scan sliders support touch dragging.
- Power saver reduces metric refresh rates and expensive decoration.

## Language and RTL
Arabic is the default. Tap `EN` for English and `AR` to switch back. The language helper applies right-to-left direction and alignment where appropriate.

## Keys
No production keys live in the repository. Configure `Config.Security.Endpoint` with an authoritative backend and read `SECURITY.md` before release.
