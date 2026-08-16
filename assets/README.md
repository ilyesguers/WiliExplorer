# Administrator-managed artwork

Place approved source artwork in `assets/branding/` and update `src/Theme/Assets.lua` through a reviewed administrator commit.

## Important

Roblox UI cannot display a raw GitHub PNG URL directly. The administrator must:

1. Add the source PNG here for version history.
2. Upload the image through the project’s approved Roblox creator account.
3. Put its `rbxassetid://...` value in `Assets.lua`.
4. Submit and review the change before release.

Empty asset IDs intentionally fall back to semantic text icons, so missing artwork never breaks the UI.
