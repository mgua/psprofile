<#
.SYNOPSIS
    Setup development links for unified drive access
    This avoids referencing UNC paths or drive letters from within
    Unix-oriented dev tools. Allows better cross-platform compatibility.

.DESCRIPTION
    Creates junction points (local drives) and symbolic links (network shares)
    under ~/mnt for consistent path access across all storage locations.
    Safe to run multiple times - checks existing links.

    Configuration is read from .dev-links.psd1 (searches script directory first, then $HOME)

.NOTES
    - Local drives: No admin required (uses junctions)
    - Network shares: Requires admin (uses symlinks)
    
.PERMISSIONS
    # For current user only (no admin needed)
    Unblock-File .\setup-dev-links.ps1
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

.EXAMPLES
    # First time setup
    .\setup-dev-links.ps1

    # Dry run to see what would happen
    .\setup-dev-links.ps1 -DryRun

    # Force recreate all links
    .\setup-dev-links.ps1 -Force

    # For network shares (run as admin)
    Start-Process powershell -Verb RunAs -ArgumentList "-File .\setup-dev-links.ps1"
#>

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$DryRun
)

# ============================================================================
# CONFIGURATION
# ============================================================================

$ConfigFileName = ".dev-links.psd1"
$ConfigPath = $null

# Search order: script directory first, then $HOME
$SearchPaths = @(
    (Join-Path $PSScriptRoot $ConfigFileName),
    (Join-Path $HOME $ConfigFileName)
)

foreach ($path in $SearchPaths) {
    if (Test-Path $path) {
        $ConfigPath = $path
        break
    }
}

if (-not $ConfigPath) {
    Write-Error "Configuration file not found"
    Write-Host "Searched in:" -ForegroundColor Yellow
    foreach ($path in $SearchPaths) {
        Write-Host "  - $path" -ForegroundColor Gray
    }
    Write-Host @"

Please create $ConfigFileName in one of those locations with content like:

@{
    LinksRoot = "~/mnt"
    
    LocalDrives = @{
        "loc_d" = "D:\"
    }
    
    NetworkShares = @{
        "net_share" = "\\server\share"
    }
    
    Projects = @{
    }
}
"@ -ForegroundColor Yellow
    exit 1
}

try {
    $Config = Import-PowerShellDataFile -Path $ConfigPath
}
catch {
    Write-Error "Failed to parse configuration: $_"
    exit 1
}

# Expand ~ in LinksRoot
if ($Config.LinksRoot -match '^~[/\\]?') {
    $Config.LinksRoot = $Config.LinksRoot -replace '^~', $HOME
}

# Ensure hashtables exist (empty if not defined)
if (-not $Config.LocalDrives) { $Config.LocalDrives = @{} }
if (-not $Config.NetworkShares) { $Config.NetworkShares = @{} }
if (-not $Config.Projects) { $Config.Projects = @{} }

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Normalize-Path {
    param([string]$Path)
    # Convert forward slashes to backslashes for Windows compatibility
    # Also handle //server -> \\server
    $normalized = $Path -replace '/', '\'
    # Remove trailing backslash unless it's a drive root
    if ($normalized -notmatch '^[A-Z]:\\$' -and $normalized.EndsWith('\')) {
        $normalized = $normalized.TrimEnd('\')
    }
    return $normalized
}

function Test-IsAdmin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-LinkExists {
    param([string]$Path)
    
    if (Test-Path $Path) {
        $item = Get-Item $Path -Force -ErrorAction SilentlyContinue
        return ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -eq [System.IO.FileAttributes]::ReparsePoint
    }
    return $false
}

function Get-LinkTarget {
    param([string]$Path)
    
    if (Test-LinkExists $Path) {
        $item = Get-Item $Path -Force
        return $item.Target
    }
    return $null
}

function Test-TargetMatch {
    param(
        [string]$Current,
        [string]$Expected
    )
    # Normalize both for comparison
    $c = (Normalize-Path $Current).TrimEnd('\')
    $e = (Normalize-Path $Expected).TrimEnd('\')
    return $c -eq $e
}

function New-SafeJunction {
    param(
        [string]$Link,
        [string]$Target
    )
    
    $Target = Normalize-Path $Target
    $Link = Normalize-Path $Link
    
    if (-not (Test-Path $Target)) {
        Write-Warning "Target does not exist: $Target"
        return $false
    }
    
    if (Test-Path $Link) {
        if (Test-LinkExists $Link) {
            $currentTarget = Get-LinkTarget $Link
            if (Test-TargetMatch $currentTarget $Target) {
                Write-Host "  [OK] Junction already exists: $Link -> $Target" -ForegroundColor Green
                return $true
            }
            else {
                Write-Warning "Link exists but points elsewhere: $Link -> $currentTarget"
                if ($Force) {
                    Write-Host "  Removing old link..." -ForegroundColor Yellow
                    Remove-Item $Link -Force
                }
                else {
                    Write-Warning "Use -Force to replace"
                    return $false
                }
            }
        }
        else {
            Write-Warning "Path exists but is not a link: $Link"
            return $false
        }
    }
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would create junction: $Link -> $Target" -ForegroundColor Cyan
        return $true
    }
    
    # Create junction and verify
    $output = cmd /c mklink /J "$Link" "$Target" 2>&1
    
    if (Test-LinkExists $Link) {
        Write-Host "  [OK] Created junction: $Link -> $Target" -ForegroundColor Green
        return $true
    }
    else {
        Write-Error "Failed to create junction: $output"
        return $false
    }
}

function New-SafeSymlink {
    param(
        [string]$Link,
        [string]$Target
    )
    
    $Target = Normalize-Path $Target
    $Link = Normalize-Path $Link
    
    if (-not (Test-IsAdmin)) {
        Write-Warning "Symbolic links require Administrator privileges"
        Write-Host "  Please run as Administrator to create: $Link" -ForegroundColor Yellow
        return $false
    }
    
    if (-not (Test-Path $Target)) {
        Write-Warning "Target not accessible: $Target"
        return $false
    }
    
    if (Test-Path $Link) {
        if (Test-LinkExists $Link) {
            $currentTarget = Get-LinkTarget $Link
            if (Test-TargetMatch $currentTarget $Target) {
                Write-Host "  [OK] Symlink already exists: $Link -> $Target" -ForegroundColor Green
                return $true
            }
            else {
                Write-Warning "Link exists but points elsewhere: $Link -> $currentTarget"
                if ($Force) {
                    Write-Host "  Removing old link..." -ForegroundColor Yellow
                    Remove-Item $Link -Force
                }
                else {
                    Write-Warning "Use -Force to replace"
                    return $false
                }
            }
        }
        else {
            Write-Warning "Path exists but is not a link: $Link"
            return $false
        }
    }
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would create symlink: $Link -> $Target" -ForegroundColor Cyan
        return $true
    }
    
    # Create symlink and verify
    $output = cmd /c mklink /D "$Link" "$Target" 2>&1
    
    if (Test-LinkExists $Link) {
        Write-Host "  [OK] Created symlink: $Link -> $Target" -ForegroundColor Green
        return $true
    }
    else {
        Write-Error "Failed to create symlink: $output"
        return $false
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

Write-Host "`n+------------------------------------------------------------+" -ForegroundColor Cyan
Write-Host "|  Development Links Setup                                   |" -ForegroundColor Cyan
Write-Host "+------------------------------------------------------------+`n" -ForegroundColor Cyan

Write-Host "Config: $ConfigPath" -ForegroundColor Gray

if ($DryRun) {
    Write-Host "[DRY RUN MODE - No changes will be made]`n" -ForegroundColor Yellow
}

$isAdmin = Test-IsAdmin
if (-not $isAdmin) {
    Write-Warning "Not running as Administrator - network share symlinks will be skipped"
    Write-Host "  Run as Admin to enable network share mounting`n" -ForegroundColor Yellow
}

# Normalize LinksRoot
$Config.LinksRoot = Normalize-Path $Config.LinksRoot

# Create root directory
if (-not (Test-Path $Config.LinksRoot)) {
    if ($DryRun) {
        Write-Host "[DRY RUN] Would create: $($Config.LinksRoot)" -ForegroundColor Cyan
    }
    else {
        New-Item -ItemType Directory -Path $Config.LinksRoot -Force | Out-Null
        Write-Host "Created links root: $($Config.LinksRoot)`n" -ForegroundColor Green
    }
}
else {
    Write-Host "Links root exists: $($Config.LinksRoot)`n" -ForegroundColor Green
}

# Process local drives (junctions)
if ($Config.LocalDrives.Count -gt 0) {
    Write-Host "-------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "LOCAL DRIVES (Junctions - No admin required)" -ForegroundColor Yellow
    Write-Host "-------------------------------------------------------------" -ForegroundColor Gray
    
    foreach ($mount in $Config.LocalDrives.GetEnumerator()) {
        $linkPath = Join-Path $Config.LinksRoot $mount.Key
        $targetPath = $mount.Value
        
        Write-Host "`n$($mount.Key):"
        New-SafeJunction -Link $linkPath -Target $targetPath | Out-Null
    }
}

# Process network shares (symlinks)
if ($Config.NetworkShares.Count -gt 0) {
    Write-Host "`n-------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "NETWORK SHARES (Symlinks - Admin required)" -ForegroundColor Yellow
    Write-Host "-------------------------------------------------------------" -ForegroundColor Gray
    
    foreach ($mount in $Config.NetworkShares.GetEnumerator()) {
        $linkPath = Join-Path $Config.LinksRoot $mount.Key
        $targetPath = $mount.Value
        
        Write-Host "`n$($mount.Key):"
        New-SafeSymlink -Link $linkPath -Target $targetPath | Out-Null
    }
}

# Process project folders
if ($Config.Projects.Count -gt 0) {
    Write-Host "`n-------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "PROJECT FOLDERS" -ForegroundColor Yellow
    Write-Host "-------------------------------------------------------------" -ForegroundColor Gray
    
    foreach ($mount in $Config.Projects.GetEnumerator()) {
        $linkPath = Join-Path $Config.LinksRoot $mount.Key
        $targetPath = $mount.Value
        
        Write-Host "`n$($mount.Key):"
        
        # Determine if target is network path
        if ($targetPath -match '^\\\\' -or $targetPath -match '^//') {
            New-SafeSymlink -Link $linkPath -Target $targetPath | Out-Null
        }
        else {
            New-SafeJunction -Link $linkPath -Target $targetPath | Out-Null
        }
    }
}

# Summary
Write-Host "`n+------------------------------------------------------------+" -ForegroundColor Cyan
Write-Host "|  Setup Complete                                            |" -ForegroundColor Cyan
Write-Host "+------------------------------------------------------------+`n" -ForegroundColor Cyan

if (-not $DryRun) {
    Write-Host "Your development links are ready at:" -ForegroundColor Green
    Write-Host "  $($Config.LinksRoot)`n" -ForegroundColor White
    
    Write-Host "Quick access commands:" -ForegroundColor Yellow
    Write-Host "  cd ~/mnt              # Browse all links"
    Write-Host "  cd ~/mnt/loc_d        # Access D: drive"
    Write-Host "  nvim ~/mnt/loc_d/...  # Edit files with Neovim"
    Write-Host ""
}

# List current links
if (-not $DryRun -and (Test-Path $Config.LinksRoot)) {
    Write-Host "Current links:" -ForegroundColor Yellow
    Get-ChildItem $Config.LinksRoot -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            $target = $_.Target
            Write-Host "  $($_.Name) -> $target" -ForegroundColor Gray
        }
    }
    Write-Host ""
}
