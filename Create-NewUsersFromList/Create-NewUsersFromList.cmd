@echo off
powershell.exe -ExecutionPolicy Bypass -File "%~d0%~p0%~n0.ps1"
If not "%errorlevel%"=="0" (
Echo command failed
Pause
) Else (
Echo command success
Pause
)
