@echo off
setlocal
title Diagnostika HP DeskJet 2910

:: Znovuspusteni jako spravce
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell.exe -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "OUT=%USERPROFILE%\Desktop\HP2910_diagnostika.txt"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
"$ErrorActionPreference='SilentlyContinue'; ^
$out='%OUT%'; ^
'HP DeskJet 2910 - diagnostika' | Out-File -FilePath $out -Encoding utf8; ^
('Datum: ' + (Get-Date)) | Out-File $out -Append -Encoding utf8; ^
'' | Out-File $out -Append; ^
'=== TISKARNY ===' | Out-File $out -Append; ^
Get-Printer | Format-List Name,DriverName,PortName,PrinterStatus,Type,Shared,Published | Out-String | Out-File $out -Append; ^
'=== OVLADACE TISKAREN ===' | Out-File $out -Append; ^
Get-PrinterDriver | Format-List Name,Manufacturer,MajorVersion,InfPath | Out-String | Out-File $out -Append; ^
'=== PORTY ===' | Out-File $out -Append; ^
Get-PrinterPort | Format-List Name,Description,PrinterHostAddress,PortNumber | Out-String | Out-File $out -Append; ^
'=== WIN32_PRINTER ===' | Out-File $out -Append; ^
Get-CimInstance Win32_Printer | Format-List Name,DriverName,PortName,Default,WorkOffline,PrinterStatus,DetectedErrorState | Out-String | Out-File $out -Append; ^
'=== USB / PNP ZARIZENI SOUVISEJICI S HP NEBO TISKEM ===' | Out-File $out -Append; ^
Get-PnpDevice | Where-Object { $_.FriendlyName -match 'HP|DeskJet|USB Printing|Printer' -or $_.Class -match 'Printer|USB' } | ^
Format-Table -AutoSize Status,Class,FriendlyName,InstanceId | Out-String -Width 300 | Out-File $out -Append; ^
'=== PNP OVLADACE ===' | Out-File $out -Append; ^
Get-CimInstance Win32_PnPSignedDriver | Where-Object { $_.DeviceName -match 'HP|DeskJet|Printer|USB Printing' } | ^
Format-List DeviceName,DriverProviderName,DriverVersion,InfName,DeviceID | Out-String | Out-File $out -Append; ^
'=== PRINT SPOOLER ===' | Out-File $out -Append; ^
Get-Service Spooler | Format-List Name,Status,StartType | Out-String | Out-File $out -Append; ^
'=== POSLEDNI UDALOSTI PRINTSERVICE ===' | Out-File $out -Append; ^
Get-WinEvent -LogName 'Microsoft-Windows-PrintService/Admin' -MaxEvents 40 | ^
Select-Object TimeCreated,Id,LevelDisplayName,Message | Format-List | Out-String | Out-File $out -Append; ^
'=== POSLEDNI UDALOSTI SYSTEM - PRINT/USB ===' | Out-File $out -Append; ^
Get-WinEvent -LogName System -MaxEvents 300 | Where-Object { $_.ProviderName -match 'Print|USB|Kernel-PnP' -or $_.Message -match 'printer|DeskJet|HP|USB' } | ^
Select-Object -First 80 TimeCreated,Id,ProviderName,LevelDisplayName,Message | Format-List | Out-String | Out-File $out -Append; ^
'=== PNPUTIL ENUM-DEVICES - CLASS PRINTER ===' | Out-File $out -Append; ^
(& pnputil.exe /enum-devices /class Printer 2^>^&1) | Out-File $out -Append; ^
'=== PNPUTIL ENUM-DRIVERS ===' | Out-File $out -Append; ^
(& pnputil.exe /enum-drivers 2^>^&1) | Select-String -Pattern 'HP|DeskJet|Printer|oem.*inf|Provider Name|Class Name|Driver Version' -Context 0,2 | Out-String | Out-File $out -Append; ^
Write-Host ''; ^
Write-Host 'Diagnostika dokoncena.' -ForegroundColor Green; ^
Write-Host ('Soubor je na plose: ' + $out); ^
Write-Host ''; ^
Read-Host 'Stisknete Enter pro ukonceni'"

endlocal
