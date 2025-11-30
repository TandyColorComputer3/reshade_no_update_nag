# Building ReShade64.dll

## Option 1: Visual Studio (Easiest)

1. Open `ReShade.sln` in Visual Studio
2. Select **Release** configuration and **x64** platform from the dropdowns at the top
3. Right-click on the **ReShade** project → **Build**
   - Or use menu: **Build** → **Build Solution** (Ctrl+Shift+B)
4. The compiled DLL will be in: `bin\x64\Release\ReShade64.dll`

## Option 2: Command Line with MSBuild

Open **Developer Command Prompt for VS** (or PowerShell with Visual Studio environment):

```powershell
# Navigate to project directory
cd C:\Users\trellen\source\repos\reshade

# Build Release x64 configuration
msbuild ReShade.sln /p:Configuration=Release /p:Platform=x64 /t:ReShade
```

Output will be in: `bin\x64\Release\ReShade64.dll`

## Option 3: Using the Build Script

The project includes a PowerShell build script, but it builds both 32-bit and 64-bit:

```powershell
cd C:\Users\trellen\source\repos\reshade
.\tools\build_release.ps1
```

This will build both ReShade32.dll and ReShade64.dll in their respective Release folders.

## Quick Build Command (if MSBuild is in PATH)

```powershell
msbuild ReShade.sln /p:Configuration=Release /p:Platform=x64 /t:ReShade /m
```

The `/m` flag enables parallel builds for faster compilation.

## Output Location

After building, your ReShade64.dll will be located at:
```
bin\x64\Release\ReShade64.dll
```

## Notes

- Make sure you have Visual Studio 2019 or later with C++ desktop development workload installed
- The first build may take several minutes as it compiles all dependencies
- Subsequent builds will be faster due to incremental compilation

