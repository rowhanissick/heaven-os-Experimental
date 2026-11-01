@echo off
echo ===================================================
echo     Pushing HeavenOS-Kiosk Changes to GitHub
echo ===================================================
cd /d "%~dp0"
git add .
git commit -m "Smart minimize guard and terminal disabled"
git push origin main
if %errorlevel% neq 0 (
    echo.
    echo [!] Agar push nahi hua toh GitHub Token chahiye hoga.
    echo     GitHub Settings - Developer Settings - Personal Access Tokens - Generate
    echo     Phir terminal me run karo:
    echo     git remote set-url origin https://YOUR_TOKEN@github.com/rowhanissick/heaven-os-Experimental.git
    echo.
)
pause
