@echo off
setlocal

set "ENGINE_DIR=%~dp0engine"
set "MOD_ID=crossfire"

set "SERVER_NAME=Crossfire Dedicated Server"
set "SERVER_PORT=1234"
set "SERVER_PLAYERS=8"

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

echo Starting Crossfire dedicated server...
echo Server Name : %SERVER_NAME%
echo Port        : %SERVER_PORT%
echo Max Players : %SERVER_PLAYERS%
echo.

cd /d "%ENGINE_DIR%"
OpenRA.exe Game.Mod=%MOD_ID% Launch.Dedicated=true Server.Name="%SERVER_NAME%" Server.ExternalPort=%SERVER_PORT% Server.MaxPlayers=%SERVER_PLAYERS%
