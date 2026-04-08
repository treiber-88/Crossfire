@echo off
setlocal

set "ENGINE_DIR=%~dp0engine"
set "MOD_ID=crossfire"

if not exist "%ENGINE_DIR%\OpenRA.exe" (
    echo OpenRA engine not found. Please run make.cmd first.
    pause
    exit /b 1
)

if not exist "%ENGINE_DIR%\mods\%MOD_ID%\mod.yaml" (
    echo Crossfire mod not found in engine folder. Please run make.cmd first.
    pause
    exit /b 1
)

echo Starting Crossfire...
cd /d "%ENGINE_DIR%"
start "" OpenRA.exe Game.Mod=%MOD_ID%
