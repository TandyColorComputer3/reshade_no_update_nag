# Custom Modifications

This fork contains custom modifications to ReShade for personal use. These changes are not intended for upstream contribution.

## Modifications

### 1. Disabled Update Checks
- **File**: `source/runtime_update_check.cpp`
- **Change**: Hard-disabled online update checks and version notifications
- **Details**: Added early return in `check_for_update()` to prevent network calls to GitHub API

### 2. Suppressed Uncommanded Popups/Toasts
- **Files**: `source/runtime.hpp`, `source/runtime_gui.cpp`
- **Change**: All popups, toasts, and notifications are suppressed unless the user explicitly opens the overlay with HOME key
- **Details**: 
  - Added `_overlay_explicitly_opened` flag to track user-initiated overlay opening
  - Modified conditions for splash window, message windows, statistics, and font scaling popup to only show when overlay is explicitly opened
  - Ensures a clean, non-intrusive experience unless user actively engages with overlay

### 3. Auto-Focus Home Tab
- **File**: `source/runtime_gui.cpp`
- **Change**: Home tab is automatically focused/selected when overlay is opened
- **Details**: When user presses HOME to open overlay, the Home tab is automatically brought to front, showing shaders immediately without requiring manual tab selection

### 4. Auto-Reload Effects After Reset
- **Files**: `source/runtime.hpp`, `source/runtime.cpp`
- **Change**: Effects automatically reload after swapchain reset (e.g., alt-tab, checkpoint reload)
- **Details**:
  - Added `_effects_were_destroyed` flag to track when effects are destroyed by `on_reset()`
  - Modified `update_effects()` to automatically trigger `reload_effects()` when effects were destroyed
  - Resets `_reload_count` in `on_reset()` to ensure proper UI state
  - Ensures shaders remain loaded and visible without manual reload after focus loss or game checkpoint reloads

## Building

Follow the standard ReShade build instructions in README.md. The modifications are source code changes only and don't affect the build process.

## License

This fork maintains the same BSD 3-clause license as the original ReShade project. See LICENSE.md for details.

