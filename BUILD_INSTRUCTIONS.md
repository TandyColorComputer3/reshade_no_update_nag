# Building and updating `ReShade64.dll` efficiently

If you only care about refreshing your customized `ReShade64.dll`, you do **not** need to open the Visual Studio IDE and click through the solution by hand every time. This repository now includes a small PowerShell helper that finds MSBuild automatically and builds only the 64-bit `ReShade` target.

## One-time setup

Install one of these on Windows:

- Visual Studio 2022 **or** Build Tools for Visual Studio 2022
- Workload: **Desktop development with C++**
- Git with submodule support

You do **not** need Visual Studio 2017 specifically. Visual Studio 2019/2022 Build Tools are sufficient as long as the C++ toolchain is installed.

## Fast path: build only `ReShade64.dll`

From a regular PowerShell window in the repo root:

```powershell
.\tools\build_reshade64.ps1
```

That script:

1. locates `MSBuild.exe` via `vswhere`,
2. updates the embedded version header,
3. builds only the `ReShade` project for `Release|64-bit`, and
4. leaves the output at `bin\x64\Release\ReShade64.dll`.

If you want a clean rebuild:

```powershell
.\tools\build_reshade64.ps1 -Clean
```

If you want the finished DLL copied somewhere immediately:

```powershell
.\tools\build_reshade64.ps1 -OutputPath 'C:\temp\ReShade64.dll'
```

## Efficient update workflow for future upstream releases

### Option A: keep your fork and rebase/merge occasionally

This is the easiest long-term workflow if you want to refresh every few years:

```bash
git remote add upstream https://github.com/crosire/reshade.git
git fetch upstream --tags
git checkout work
git merge upstream/main
```

After the merge, re-apply only the small fork-only changes you still want (like the update nag removal), then build with:

```powershell
.\tools\build_reshade64.ps1
```

### Option B: carry the update-nag change as a tiny patch

Since your actual update-nag change is just an early `return;` in `source/runtime_update_check.cpp`, you can keep that change as a tiny patch instead of re-discovering it manually.

Create the patch from this repo once:

```bash
git diff d49f756..c80633f -- source/runtime_update_check.cpp > update-nag.patch
```

Then in a newer upstream checkout:

```bash
git apply --3way update-nag.patch
```

If it applies cleanly, build immediately:

```powershell
.\tools\build_reshade64.ps1
```

If it does not apply cleanly, open `source/runtime_update_check.cpp`, search for `check_for_update()`, and reinsert the early return described in `PORTING_UPDATE_NAG.md`.

## Compare your fork against upstream surgically

These are the most useful commands when you only care about your custom changes:

```bash
# Show only your fork-only commits
git log --oneline upstream/main..HEAD

# Show only the current update-nag source delta
git diff upstream/main...HEAD -- source/runtime_update_check.cpp

# Search for the update-check and banner logic
rg -n "check_for_update|s_latest_version|An update is available" source
```

That is usually enough to answer: "what exactly do I still need to carry forward?"

## Output

Successful builds produce:

```
bin\x64\Release\ReShade64.dll
```

## If Doom: The Dark Ages (or another game) forces a refresh

A practical low-friction routine is:

1. `git fetch upstream --tags`
2. `git merge upstream/main`
3. re-apply or verify the tiny `check_for_update()` patch
4. run `.\tools\build_reshade64.ps1`
5. copy `bin\x64\Release\ReShade64.dll` into your game setup

That keeps the process down to Git + one PowerShell command, without going back through the Visual Studio GUI.
