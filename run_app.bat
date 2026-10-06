@echo off
echo =========================================================
echo 🚀 Starting SignBridge AI Self-Contained Project Server
echo =========================================================

echo [1/2] Launching Python Backend Server from project backend folder...
start "SignBridge AI Backend Server" cmd /k "cd /d %~dp0backend && python api_server.py"

timeout /t 2 >nul

echo [2/2] Launching Flutter Application...
flutter run
