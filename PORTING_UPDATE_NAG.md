# Porting the ReShade "update nag" removal to newer versions

This repository already removes the update nag by short-circuiting the update-check path in `reshade::runtime::check_for_update()`.

## What the current fork changed

The relevant change is intentionally tiny:

- File: `source/runtime_update_check.cpp`
- Function: `reshade::runtime::check_for_update()`
- Modification: insert an immediate `return;` at the top of the function, before any network access or version parsing happens

Because `s_latest_version` stays at `{ 0, 0, 0 }`, the Home tab never reaches the "An update is available" branch in `source/runtime_gui.cpp`.

In other words:

1. `runtime.cpp` calls `check_for_update()` during startup.
2. Your fork returns immediately, so no GitHub tag lookup happens.
3. `s_latest_version` is never populated with a newer version.
4. The UI update banner condition stays false.

## Fastest way to re-apply this to a newer upstream ReShade

If the newer version still has `source/runtime_update_check.cpp` and the same function name, do this in your newer clone:

```bash
git log --oneline -n 20
git show c80633f -- source/runtime_update_check.cpp
```

Then manually make the same edit:

```cpp
void reshade::runtime::check_for_update()
{
    // Hard-disable online update checks + nags
    return;

    ... existing upstream code ...
}
```

That is the safest forward-port, because it avoids accidentally bringing along your other fork-only changes.

## Re-applying it with Git when both repos share history

If your newer repo is based on the same upstream history, you can also reuse the old commit as a starting point:

```bash
# From the newer repo
git cherry-pick -n c80633f
```

But that old commit contains more than the update-nag removal, so do **not** commit immediately. Instead keep only the update-check change:

```bash
# Keep only the file relevant to the nag removal
git restore --staged .
git restore .
git checkout c80633f -- source/runtime_update_check.cpp
```

Then review the diff:

```bash
git diff -- source/runtime_update_check.cpp
```

If the file layout changed upstream, just copy the two-line patch manually instead of forcing the checkout.

## How to locate the right code if upstream moved it

If newer ReShade reorganized the files, search for the same behavior instead of the same filename:

```bash
rg -n "check_for_update|latest_version|An update is available|api.github.com/repos/crosire/reshade/tags" source
```

You are looking for one or both of these pieces:

- The function that fetches the latest release/tag version.
- The GUI code that compares the fetched version against `VERSION_MAJOR`, `VERSION_MINOR`, and `VERSION_REVISION`.

The most robust patch point is still the fetch/check function. Returning early there prevents both the network call and the nag.

## Why patching `check_for_update()` is better than only hiding the text

You *could* remove or change the UI text in the Home tab, but that is weaker than the current approach.

Patching only the GUI would still allow ReShade to:

- contact GitHub for version information,
- store the latest version in memory, and
- potentially use that value elsewhere later.

Patching `check_for_update()` keeps the behavior simple and future-proof:

- no request,
- no parsed version,
- no banner.

## Minimal patch to carry forward

When in doubt, this is the entire change you want to preserve conceptually:

```diff
 void reshade::runtime::check_for_update()
 {
+    // Hard-disable online update checks + nags
+    return;
+
     ...
 }
```

## Suggested workflow for every new ReShade release

1. Merge or rebase onto the newer upstream version.
2. Search for `check_for_update` and `s_latest_version`.
3. Reinsert the early return at the top of the update-check function.
4. Verify that the Home tab still keys off the same latest-version state.
5. Build and smoke-test ReShade.

Useful commands:

```bash
rg -n "check_for_update|s_latest_version|An update is available" source

git diff -- source/runtime_update_check.cpp source/runtime_gui.cpp
```

## If upstream eventually removes `check_for_update()`

If ReShade later replaces this with a different update service, apply the same principle at the new source of truth:

- stop the code before it fetches or records the newest version, or
- force the recorded "latest version" value to match the current build.

The cleanest option remains: **return before the network/version-detection logic runs**.
