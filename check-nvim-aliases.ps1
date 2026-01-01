# Diagnostic script to check nvim alias conflicts
# Run this before loading your profile to see what's already defined

Write-Host "=== Checking for existing nvim-related aliases ===" -ForegroundColor Cyan
Write-Host ""

$aliasNames = @('nv', 'nvim', 'vi', 'vim', 'nvim-new', 'nv-new')
$foundIssues = $false

foreach ($aliasName in $aliasNames) {
    $alias = Get-Alias -Name $aliasName -ErrorAction SilentlyContinue
    
    if ($alias) {
        Write-Host "Alias '$aliasName' exists:" -ForegroundColor Yellow
        Write-Host "  Definition : $($alias.Definition)" -ForegroundColor White
        Write-Host "  Options    : $($alias.Options)" -ForegroundColor White
        Write-Host "  Source     : $($alias.Source)" -ForegroundColor White
        Write-Host "  ModuleName : $($alias.ModuleName)" -ForegroundColor White
        
        # Check for problematic options
        if ($alias.Options -match 'AllScope') {
            Write-Host "  ERROR: This alias has AllScope option!" -ForegroundColor Red
            Write-Host "         AllScope aliases cannot be removed or overridden normally." -ForegroundColor Red
            $foundIssues = $true
        }
        if ($alias.Options -match 'ReadOnly') {
            Write-Host "  WARNING: This alias is READ-ONLY!" -ForegroundColor Red
            $foundIssues = $true
        }
        if ($alias.Options -match 'Constant') {
            Write-Host "  ERROR: This alias is CONSTANT and cannot be changed!" -ForegroundColor Red
            $foundIssues = $true
        }
        Write-Host ""
    } else {
        Write-Host "Alias '$aliasName' not found (OK)" -ForegroundColor Green
    }
}

Write-Host "=== Checking loaded modules that might define these aliases ===" -ForegroundColor Cyan
Write-Host ""

$loadedModules = Get-Module | Select-Object Name, ExportedAliases

foreach ($module in $loadedModules) {
    $nvimAliases = $module.ExportedAliases.Keys | Where-Object { $_ -in $aliasNames }
    if ($nvimAliases) {
        Write-Host "Module '$($module.Name)' exports: $($nvimAliases -join ', ')" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Checking where 'nv' alias is defined ===" -ForegroundColor Cyan

# Try to find which profile or module file defines it
$nvAlias = Get-Alias nv -ErrorAction SilentlyContinue
if ($nvAlias -and $nvAlias.Source) {
    $module = Get-Module -Name $nvAlias.Source -ErrorAction SilentlyContinue
    if ($module) {
        Write-Host "The 'nv' alias comes from module: $($module.Name)" -ForegroundColor Yellow
        Write-Host "  Module Path: $($module.Path)" -ForegroundColor White
        Write-Host ""
        Write-Host "To prevent this module from loading, you can:" -ForegroundColor Cyan
        Write-Host "  1. Remove the module: Remove-Module $($module.Name)" -ForegroundColor White
        Write-Host "  2. Prevent auto-import by editing your profile" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "=== Recommendation ===" -ForegroundColor Cyan

if ($foundIssues) {
    Write-Host "ISSUES FOUND! The updated profile.ps1 includes Set-AliasSafe function" -ForegroundColor Yellow
    Write-Host "that handles AllScope and ReadOnly aliases automatically." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options to fix:" -ForegroundColor White
    Write-Host "  1. Use the updated profile.ps1 with Set-AliasSafe (RECOMMENDED)" -ForegroundColor Green
    Write-Host "  2. Find and disable the module creating AllScope aliases" -ForegroundColor Yellow
    Write-Host "  3. Use different alias names (e.g., nvl instead of nv)" -ForegroundColor Yellow
} else {
    Write-Host "No issues found. Your profile should load correctly." -ForegroundColor Green
}

Write-Host ""
