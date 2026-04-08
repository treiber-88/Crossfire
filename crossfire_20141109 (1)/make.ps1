$ErrorActionPreference = "Stop"

# Self-elevate: if not running as admin, relaunch with UAC prompt
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting administrator privileges..."
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
    exit
}

$Here        = Split-Path -Parent $MyInvocation.MyCommand.Path
$EngineDir   = Join-Path $Here "engine"
$ModsDir     = Join-Path $EngineDir "mods"
$ModId       = "crossfire"
$ModSrc      = Join-Path $Here "crossfire"
$TempInstall = "C:\openra_temp_install"  # must have no spaces for NSIS /D= flag

# Known OpenRA releases compatible with this mod (closest to release-20141109)
$CandidateVersions = @(
    "release-20141029",
    "release-20141119",
    "release-20150424",
    "release-20150614"
)

Write-Host "========================================"
Write-Host " Crossfire Mod - Engine Setup"
Write-Host "========================================"
Write-Host ""

# ----------------------------------------------------------------
# STEP 1: Download engine if not already present
# ----------------------------------------------------------------
if (Test-Path (Join-Path $EngineDir "OpenRA.exe")) {
    Write-Host "Engine already present, skipping download."
} else {
    if (-not (Test-Path $EngineDir)) {
        New-Item -ItemType Directory -Path $EngineDir | Out-Null
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $headers = @{ 'User-Agent' = 'OpenRA-Crossfire-Setup' }

    # Find the first candidate version that has release assets on GitHub
    $chosenAssets  = $null
    $chosenVersion = $null

    foreach ($ver in $CandidateVersions) {
        Write-Host "Checking GitHub for $ver ..."
        try {
            $apiUrl  = "https://api.github.com/repos/OpenRA/OpenRA/releases/tags/$ver"
            $release = Invoke-RestMethod -Uri $apiUrl -Headers $headers
            if ($release.assets -and $release.assets.Count -gt 0) {
                $chosenAssets  = $release.assets
                $chosenVersion = $ver
                Write-Host "Found release: $ver"
                break
            }
        } catch {
            # 404 or network issue - try next version
        }
    }

    if (-not $chosenAssets) {
        Write-Host ""
        Write-Host "ERROR: Could not find a downloadable OpenRA release on GitHub."
        Write-Host "Please download OpenRA manually from:"
        Write-Host "  https://github.com/OpenRA/OpenRA/releases"
        Write-Host "and extract the files to: $EngineDir"
        Read-Host "Press Enter to exit"
        exit 1
    }

    Write-Host ""
    Write-Host "Using OpenRA $chosenVersion"
    Write-Host "Available assets:"
    $chosenAssets | ForEach-Object { Write-Host "  $($_.name)" }
    Write-Host ""

    $wc = New-Object System.Net.WebClient

    # Positive filter: only Windows assets
    # .exe = NSIS Windows installer (always Windows-only)
    # .zip with "win" in the name = Windows portable zip
    $exeAsset = $chosenAssets | Where-Object { $_.name -like "*.exe" } | Select-Object -First 1
    $zipAsset = $chosenAssets | Where-Object { $_.name -like "*win*.zip" } | Select-Object -First 1

    if ($exeAsset) {
        $exeFile = Join-Path $Here $exeAsset.name
        Write-Host "Downloading $($exeAsset.name)..."
        $wc.DownloadFile($exeAsset.browser_download_url, $exeFile)

        Write-Host "Installing silently..."
        if (Test-Path $TempInstall) { Remove-Item $TempInstall -Recurse -Force }

        # NSIS: /S = silent, /D= must be absolute path with no spaces
        Start-Process -FilePath $exeFile -ArgumentList "/S /D=$TempInstall" -Wait -NoNewWindow
        Remove-Item $exeFile -ErrorAction SilentlyContinue

        if (-not (Test-Path (Join-Path $TempInstall "OpenRA.exe"))) {
            Write-Host ""
            Write-Host "ERROR: Silent install failed - OpenRA.exe not found in $TempInstall"
            Write-Host "Try running the installer manually and install to: $EngineDir"
            Read-Host "Press Enter to exit"
            exit 1
        }

        Write-Host "Copying engine files..."
        Copy-Item -Path "$TempInstall\*" -Destination $EngineDir -Recurse -Force
        Remove-Item $TempInstall -Recurse -Force
        Write-Host "Engine installed."

    } elseif ($zipAsset) {
        $zipFile = Join-Path $Here $zipAsset.name
        Write-Host "Downloading $($zipAsset.name)..."
        $wc.DownloadFile($zipAsset.browser_download_url, $zipFile)
        Write-Host "Extracting..."
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $EngineDir)
        Remove-Item $zipFile -Force

        # Flatten if extracted into a subfolder
        if (-not (Test-Path (Join-Path $EngineDir "OpenRA.exe"))) {
            $sub = Get-ChildItem -Path $EngineDir -Directory | Where-Object { $_.Name -ne "mods" } | Select-Object -First 1
            if ($sub -and (Test-Path (Join-Path $sub.FullName "OpenRA.exe"))) {
                Write-Host "Flattening subfolder $($sub.Name)..."
                Get-ChildItem -Path $sub.FullName | Move-Item -Destination $EngineDir -Force
                Remove-Item $sub.FullName -Recurse -Force
            }
        }
        Write-Host "Engine extracted."

    } else {
        Write-Host ""
        Write-Host "ERROR: No Windows .exe or *win*.zip asset found for $chosenVersion"
        Write-Host "Download OpenRA manually from:"
        Write-Host "  https://github.com/OpenRA/OpenRA/releases/tag/$chosenVersion"
        Write-Host "and extract the files to: $EngineDir"
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# ----------------------------------------------------------------
# STEP 2: Copy mod files into engine mods folder
# ----------------------------------------------------------------
Write-Host ""
Write-Host "Setting up Crossfire mod..."

if (-not (Test-Path $ModsDir)) {
    New-Item -ItemType Directory -Path $ModsDir | Out-Null
}

$modDest = Join-Path $ModsDir $ModId
if (-not (Test-Path $modDest)) {
    New-Item -ItemType Directory -Path $modDest | Out-Null
}

Copy-Item -Path "$ModSrc\*" -Destination $modDest -Recurse -Force

Write-Host ""
Write-Host "========================================"
Write-Host " Done! Run launch.cmd to start the game."
Write-Host "========================================"
Write-Host ""
