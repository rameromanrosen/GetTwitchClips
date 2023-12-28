@echo off
cd /d %~dp0
powershell -NoProfile -ExecutionPolicy Unrestricted ".\PS1\GetTwitchClips.ps1"