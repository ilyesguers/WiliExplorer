# WiliExplorer 7.0 Guide

## Quick start
1. Open Explorer and select a service.
2. Search by item name, class, or full path, filter by any of 13 categories, or sort by name/type.
3. Select an item to open the **Universal Viewer** — a real preview for every type.
4. Long-press any row for the context menu (copy/clone/delete).

## Universal Viewer v7
Every file gets a real preview, whatever its type:

- **Scripts:** fully syntax-highlighted code with edit/save/run.
- **Sounds:** embedded player (play/pause/loop/volume/speed).
- **Images & video:** large preview + asset ID copy.
- **Models & parts:** auto-rotating 3D preview.
- **Animations:** metadata + play on your character.
- **GUI:** scaled miniature preview with zoom control.
- **Effects & lights:** live preview with direct controls.
- **Values & remotes:** inline editor + fire/invoke.
- **Anything else:** rich info + editable Properties tab + tags + attributes.

## Window controls
Top-bar buttons (language/DEV/minimize/close) live in an automatic `UIListLayout` cluster — no overlaps — with hover tooltips and icons separated from text.

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
