# ==========================================
#  Enable Apple Device Forwarding for WSL
#  Requires: Administrator privileges
# ==========================================

# --- Check for Administrator rights ---
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent() `
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "Elevating to Administrator..."
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# --- Detect Windows IP used by WSL ---
$WindowsWSLIP = wsl.exe -- ip route list default | ForEach-Object {
    ($_ -split '\s+')[2]
}

if (-not $WindowsWSLIP) {
    Write-Error "Failed to detect Windows IP from WSL."
    exit 1
}

Write-Host "Detected Windows host IP for WSL: $WindowsWSLIP"

# --- Configuration variables ---
$RuleName  = "WSLAppleDevice"
$Port      = 27015
$Interface = 'vEthernet (WSL (Hyper-V firewall))'

# ---- FIREWALL RULE ----
# Firewall rule to allow WSL to access to port
# 27015 (AppleDevice) on the host
Write-Host "Applying firewall rule for TCP port $Port..."

# Remove existing rule if any (to ensure correct settings)
$existingRule = Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue
if ($existingRule) {
    Write-Host "Removing previous WSLAppleDevice rule ..."
    Remove-NetFirewallRule -DisplayName $RuleName
}

# Create fresh rule
New-NetFirewallRule -DisplayName $RuleName `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort $Port `
    -Action Allow `
    -InterfaceAlias $Interface


# ---- PORT FORWARDING ----
# Forwarding rule to forward port 27015 from Windows to WSL
Write-Host "Cleanup of existing forwarding rule..."
netsh interface portproxy delete v4tov4 listenport=$Port listenaddress=$WindowsWSLIP

Write-Host "Creating port proxy for port $Port..."
netsh interface portproxy add v4tov4 listenport=$Port `
        listenaddress=$WindowsWSLIP `
        connectport=$Port `
        connectaddress=127.0.0.1

# ---- FINAL CHECK ----
Write-Host ""
Write-Host "WSLAppleDevice firewall rule:"
Get-NetFirewallRule -DisplayName $RuleName
Write-Host "Current portproxy configuration:"
netsh interface portproxy show all

Write-Host ""
Write-Host "Setup complete. Apple Device forwarding is active."

# Wait up to 10 seconds for Enter
Write-Host "Press Enter to close now or wait 10 seconds..."
$timeout = 10
$start = Get-Date
while ((Get-Date) -lt $start.AddSeconds($timeout)) {
    if ([Console]::KeyAvailable) {
        $key = [Console]::ReadKey($true)
        if ($key.Key -eq 'Enter') { break }
    }
    Start-Sleep -Milliseconds 100
}
