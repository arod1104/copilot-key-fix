# Install Copilot fix -> RCtrl at Windows startup
$scriptPath = Join-Path $PSScriptRoot "copilot_a_ctrl.ahk"
$startupFolder = [Environment]::GetFolderPath("Startup")
$shortcutPath = Join-Path $startupFolder "CopilotToCtrl.lnk"

if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: copilot_a_ctrl.ahk not found in $PSScriptRoot" -ForegroundColor Red
    exit 1
}

# Check that AutoHotkey v2 is installed
$ahkPath = $null
$possiblePaths = @(
    "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe",
    "C:\Program Files\AutoHotkey\v2\AutoHotkey32.exe",
    "C:\Program Files\AutoHotkey\AutoHotkey64.exe",
    "C:\Program Files\AutoHotkey\AutoHotkey.exe"
)
foreach ($p in $possiblePaths) {
    if (Test-Path $p) { $ahkPath = $p; break }
}

if (-not $ahkPath) {
    Write-Host ""
    Write-Host "AutoHotkey v2 is not installed." -ForegroundColor Red
    Write-Host "Download it from: https://www.autohotkey.com/" -ForegroundColor Yellow
    Write-Host "Install v2, then re-run this script." -ForegroundColor Yellow
    exit 1
}

Write-Host "AutoHotkey found at: $ahkPath" -ForegroundColor Green

# Create shortcut in Startup
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $ahkPath
$shortcut.Arguments = "`"$scriptPath`""
$shortcut.WorkingDirectory = $PSScriptRoot
$shortcut.Description = "Fix ASUS Copilot Key -> RCtrl"
$shortcut.Save()

Write-Host ""
Write-Host "OK: Shortcut created in Startup:" -ForegroundColor Green
Write-Host "  $shortcutPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "The fix will run automatically every time you start Windows." -ForegroundColor Green
Write-Host ""

# Run now
Write-Host "Running the fix now..." -ForegroundColor Yellow
Start-Process -FilePath $ahkPath -ArgumentList "`"$scriptPath`""
Write-Host "Done! The Copilot key should now act as RCtrl." -ForegroundColor Green
