@echo off
setlocal

set "ENGINE_DIR=%~dp0engine"
set "MOD_ID=crossfire"

if not exist "%ENGINE_DIR%\OpenRA.exe" (
    echo OpenRA engine not found. Running setup...
    echo.
    call "%~dp0make.cmd"
    if errorlevel 1 (
        echo Setup failed. Cannot launch game.
        pause
        exit /b 1
    )
)

if not exist "%ENGINE_DIR%\mods\%MOD_ID%\mod.yaml" (
    echo Crossfire mod missing. Running setup...
    echo.
    call "%~dp0make.cmd"
    if errorlevel 1 (
        echo Setup failed. Cannot launch game.
        pause
        exit /b 1
    )
)

echo Starting Crossfire...
cd /d "%ENGINE_DIR%"
start "" OpenRA.exe Game.Mod=%MOD_ID%
