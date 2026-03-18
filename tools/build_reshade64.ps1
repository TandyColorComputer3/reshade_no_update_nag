param(
    [ValidateSet('Release', 'Release Signed')]
    [string]$Configuration = 'Release',

    [switch]$Clean,

    [string]$OutputPath
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'

if (-not (Test-Path $vswhere)) {
    throw "vswhere.exe was not found. Install Visual Studio 2019/2022 Build Tools or Visual Studio with C++ support."
}

$msbuild = & $vswhere -latest -requires Microsoft.Component.MSBuild -find 'MSBuild\**\Bin\MSBuild.exe' | Select-Object -First 1
if (-not $msbuild) {
    throw "MSBuild.exe was not found via vswhere."
}

& "$PSScriptRoot\update_version.ps1" "$repoRoot\res\version.h"
$version = "$($global:ReShadeVersion[0]).$($global:ReShadeVersion[1]).$($global:ReShadeVersion[2])"

$solution = Join-Path $repoRoot 'ReShade.sln'
$target = if ($Clean) { 'Clean;ReShade' } else { 'ReShade' }

Write-Host "Building ReShade64.dll ($Configuration, 64-bit) with $msbuild" -ForegroundColor Cyan
& $msbuild $solution /m /t:$target /p:Configuration=$Configuration /p:Platform='64-bit'
if ($LASTEXITCODE -ne 0) {
    throw "MSBuild failed with exit code $LASTEXITCODE."
}

$dllPath = Join-Path $repoRoot "bin\x64\$Configuration\ReShade64.dll"
if (-not (Test-Path $dllPath)) {
    throw "Build succeeded but '$dllPath' was not found."
}

Write-Host "Built $dllPath" -ForegroundColor Green
Write-Host "Version: $version" -ForegroundColor Green

if ($OutputPath) {
    $resolvedOutput = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
    Copy-Item $dllPath $resolvedOutput -Force
    Write-Host "Copied ReShade64.dll to $resolvedOutput" -ForegroundColor Green
}
