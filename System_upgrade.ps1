# Check for elevation
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator."
    exit 1
}

# Ensure PSWindowsUpdate is installed
if (-not (Get-Module -ListAvailable | Where-Object { $_.Name -eq "PSWindowsUpdate" })) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name PSWindowsUpdate -Force
}
Import-Module PSWindowsUpdate


# Install Windows updates, accepting all and ignoring reboots
$updates = Get-WindowsUpdate -AcceptAll -IgnoreReboot -Verbose
if ($updates) {
    Write-Host "Installing Windows updates..."
    $updates | Install-WindowsUpdate -AcceptAll -IgnoreReboot -Verbose
    } else {
    Write-Host "No Windows updates found."
}


# Ensure Winget is installed
$wingetExe = Get-ChildItem "C:\Program Files\WindowsApps" -Recurse -Filter winget.exe -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1 -ExpandProperty FullName

if (-not $wingetExe) {

    Write-Host "Winget not found. Installing latest MSIX..."

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $release = Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest
    $asset = $release.assets | Where-Object { $_.name -match 'msixbundle' } | Select-Object -First 1

    if ($asset) {
        $bundle = "$env:TEMP\winget.msixbundle"
        Invoke-WebRequest $asset.browser_download_url -OutFile $bundle
        Add-AppxPackage -Path $bundle -DisableDevelopmentMode
        Start-Sleep 5
    }

    # Re-check after install
    $wingetExe = Get-ChildItem "C:\Program Files\WindowsApps" -Recurse -Filter winget.exe -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1 -ExpandProperty FullName
}

# Removing MS store as a source
if ($wingetExe -and (Test-Path $wingetExe)) {
    Write-Host "Removing winget MS Store from source list..."
& $wingetExe source remove -n msstore 2>$null
}

# Update Winget sources before upgrading
if ($wingetExe -and (Test-Path $wingetExe)) {
    Write-Host "Updating Winget sources..."
    & $wingetExe source update
}

# Error/Success exit code
exit $LASTEXITCODE
