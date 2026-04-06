@echo off
git pull
:: cd C:\Users\Administrator\Downloads\kornet
taskkill /f /im RCCService.exe
start /b cmd /c "cd /d 2016-roblox-main && call run.bat"
start /b cmd /c "cd /d RCCService && call run.bat"
start cmd /c "cd /d DiscordBot && call run.bat"
start cmd /c "cd /d AssetDelivery && call run.bat"
start cmd /c "cd /d korprxy && call run.bat"
start cmd /c "cd /d modapps && call run.bat"
start cmd /c "cd /d status && call run.bat"
start cmd /c "cd /d setup && call run.bat"
start cmd /c "cd /d kormons && call run.bat"
start cmd /c "cd /d voting && call run.bat"
start cmd /c "cd /d status && call run.bat"
timeout /t 2 >nul
start /b cmd /c "cd /d renderer && call run.bat"
start /b cmd /c "cd /d AssetValidationServiceV2 && call run.bat"
start cmd /c "cd /d Roblox/Roblox.Website && run.bat"
start /b redis-server.exe