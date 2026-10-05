@echo off
title Oprava HP DeskJet 2910

:: Znovuspusteni jako spravce
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo ==========================================
echo    Oprava HP DeskJet 2910
echo ==========================================
echo.

echo [1/4] Zastavuji tiskovou sluzbu...
net stop spooler >nul

echo [2/4] Mazu zasekle tiskove ulohy...
del /Q /F "%SystemRoot%\System32\spool\PRINTERS\*" >nul 2>&1

echo [3/4] Spoustim tiskovou sluzbu...
net start spooler >nul

timeout /t 2 /nobreak >nul

echo [4/4] Obnovuji HP DeskJet...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$p = Get-Printer | Where-Object { $_.Name -like '*DeskJet 2900*' -or $_.DriverName -like '*DeskJet 2900*' }; if ($p) { $p | Remove-Printer }"

net stop spooler >nul
net start spooler >nul

pnputil /scan-devices >nul

echo.
echo Cekam na znovunalezeni tiskarny...
timeout /t 8 /nobreak >nul

echo.
echo Aktualni tiskarny HP:
powershell -NoProfile -Command ^
"Get-Printer | Where-Object { $_.Name -like '*HP*' } | Format-Table Name,PortName,PrinterStatus -AutoSize"

$p = Get-Printer |
    Where-Object { $_.Name -like '*DeskJet 2900*' } |
    Select-Object -First 1

if ($p) {
    (New-Object -ComObject WScript.Network).SetDefaultPrinter($p.Name)
}

echo.
echo ==========================================
echo    Hotovo
echo ==========================================
echo.
pause
