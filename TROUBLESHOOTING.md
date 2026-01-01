# Troubleshooting Guide: AllScope Alias Conflicts

## The Problem

You're getting this error:
```
Set-Alias : The AllScope option cannot be removed from the alias 'nv'.
```

This means another module or profile has set the `nv` alias with the **AllScope** option,
which makes it persistent across all PowerShell scopes and prevents normal override.

## Solution 1: Use the Updated Profile (RECOMMENDED)

The updated `profile.ps1` includes a `Set-AliasSafe` helper function that:
- Detects if an alias has AllScope
- Preserves AllScope when redefining the alias
- Handles ReadOnly aliases too

### Steps:
1. Replace your current profile.ps1 with the updated one
2. Run `pinstall` to install it
3. Reload: `. $PROFILE`

The helper function looks like this:
```powershell
function Set-AliasSafe {
    param([string]$Name, [string]$Value, [string]$Description = "")
    
    $existingAlias = Get-Alias -Name $Name -ErrorAction SilentlyContinue
    
    if ($existingAlias -and ($existingAlias.Options -match 'AllScope')) {
        # Must preserve AllScope when redefining
        Set-Alias -Name $Name -Value $Value -Description $Description -Option AllScope -Force -Scope Global
    } else {
        Set-Alias -Name $Name -Value $Value -Description $Description -Force
    }
}
```

## Solution 2: Find and Disable the Conflicting Module

### Step 1: Run the diagnostic script
```powershell
.\check-nvim-aliases.ps1
```

This will show you which module is creating the AllScope alias.

### Step 2: Prevent the module from auto-loading

If the module is, for example, "NvimUtils", add this to the TOP of your profile.ps1:
```powershell
# Prevent module from auto-loading
$env:PSModuleAutoLoadingPreference = 'None'
Import-Module -Name <ModuleName> -ArgumentList @{ SkipAliasExport = $true }
```

Or simply don't import that module if you don't need it.

## Solution 3: Use Different Alias Names

If you can't override `nv`, use different names:
```powershell
Set-Alias -Name nvl -Value Launch-NvimLocal      # nvl = nvim local
Set-Alias -Name nvn -Value Launch-NvimNew        # nvn = nvim new
```

## Solution 4: Remove the Module After Load

Add this to your profile BEFORE setting aliases:
```powershell
# Remove the conflicting module if loaded
if (Get-Module -Name <ModuleName>) {
    Remove-Module -Name <ModuleName> -Force
}
```

## Finding the Culprit

Common modules that might set nvim-related AllScope aliases:
- Custom neovim integration modules
- Terminal enhancement modules
- Oh-My-Posh plugins
- PSReadLine extensions
- Company/organization PowerShell profiles

### Manual check:
```powershell
# Check all loaded modules
Get-Module | ForEach-Object {
    $modName = $_.Name
    $_.ExportedAliases.Keys | Where-Object { $_ -in @('nv','nvim','vi','vim') } | ForEach-Object {
        Write-Host "Module: $modName exports alias: $_"
    }
}

# Check the nv alias specifically
Get-Alias nv | Format-List *
```

## Prevention

To prevent AllScope conflicts in the future:

1. **Load your profile LAST**: Put it after all other profile loads
2. **Use Set-AliasSafe**: Always use the safe wrapper for important aliases
3. **Document conflicts**: Note which modules create conflicts in your profile comments
4. **Test in clean shell**: Occasionally test in `pwsh -NoProfile` to verify

## Quick Test

After updating your profile, test with:
```powershell
# Load the new profile
. $PROFILE

# Verify aliases work
Get-Alias nv, nvim, vi, vim | Format-Table Name, Definition, Options

# Test invocation
nv --version
```

## Still Having Issues?

If the updated profile still fails:
1. Run the diagnostic script: `.\check-nvim-aliases.ps1`
2. Look for the module creating AllScope alias
3. Either disable that module or use Solution 3 (different alias names)
4. Consider opening an issue on the conflicting module's GitHub if it's third-party
