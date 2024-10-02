# this is my powershell alias file
# mgua@tomware.it
# october-november 2023
#
# may 31 2024:
#	added la/ga aliases to show alias list
#	added ex alias to open file explorer in a specific path or in current path 
#
# jul 30 2024:
#	added lv: list python virtual env folders with *venv* name (with folder size)
#	added se: select and activate python virtualenv (with venv)
#
# aug 16 2024:
#	added lla: to somewhat replicate the linux ls -lah command that suitably 
#	shows filesizes in adequate units
#
# aug 19 2024:
#	add alias visualization in psmenu
# 
# oct 02 2024: mgua
#	add mc alias for GNU Midnight Commander (choco install mc)
#
# see https://github.com/mgua/psprofile.git
#
# save it in the file name specified by the $PROFILE variable
# if the file does not exist, we need to create it
#	New-Item -ItemType File -Path $PROFILE -Force
#
# C:\Users\<username>\Documents\profile.ps1 
#	this has to be the path pointed by the $profile variable 
# and could be different, like
#	c:\Users\<username>\Onedrive\Documents\...
#
# to reload execute (from a powershell prompt)
#	. $profile
#	
# to reload the alias file from the current folder, execute
#	. .\profile.ps1
#
# Unauthorized access error may require execution of:
#	Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
#
# see https://stackoverflow.com/questions/24914589/how-to-create-permanent-powershell-aliases
#
# check last access time of a folder/file
# Get-ChildItem | Where-Object {$_.psiscontainer} | ForEach-Object {“{0}`t{1}” -f $_.name,$_.lastaccesstime}
#
#
# WANT TO DO:
#   svenv:	select virtual environemnt: allows to choose among the different 
#		venv_* folders present in c:\users\<user>
#		the chosen penvironment is then activated, after deactivating current
#		active environment (if any)
#		
#    swsl:	select wsl: allow to choose the wsl to run among the available ones
#
#    srdi:	select and run docker image (integrates with docker running in the
#		default wsl, shows the available images and launches the chosen one)
#
#      rl:	run the specified command and pipes the output thru less pager
#
#    pspe:	Powershell profile edit: allow editing this file, and reloads 
#		its contents after the changes
#   




########################### by hapylestat menu routines BEGIN ######################
# taken from https://gist.github.com/hapylestat/b940d13b7d272fb6105a1146ddcd4e2a
# by https://github.com/hapylestat
# referenced by https://stackoverflow.com/questions/17576015/powershell-menu-selection-like-grub-curses-etc
#
## USAGE #
# $bad = "Item1","Item2"
# $selection = Menu $bad "Select menu item"
# 
# Switch ($selection){
#     0 {
#         Write-Host "Menu item 0"
#     }
#     1 {
#      Write-Host "Menu item 1"
#     }
# }


function moveCursor{ param($position)
  $host.UI.RawUI.CursorPosition = $position
}


function RedrawMenuItems{ 
    param ([array]$menuItems, $oldMenuPos=0, $menuPosition=0, $currPos)
    
    # +1 comes from leading new line in the menu
    $menuLen = $menuItems.Count + 1
    $fcolor = $host.UI.RawUI.ForegroundColor
    $bcolor = $host.UI.RawUI.BackgroundColor
    $menuOldPos = New-Object System.Management.Automation.Host.Coordinates(0, ($currPos.Y - ($menuLen - $oldMenuPos)))
    $menuNewPos = New-Object System.Management.Automation.Host.Coordinates(0, ($currPos.Y - ($menuLen - $menuPosition)))
    
    moveCursor $menuOldPos
    Write-Host "`t" -NoNewLine
    Write-Host "$oldMenuPos. $($menuItems[$oldMenuPos])" -fore $fcolor -back $bcolor -NoNewLine

    moveCursor $menuNewPos
    Write-Host "`t" -NoNewLine
    Write-Host "$menuPosition. $($menuItems[$menuPosition])" -fore $bcolor -back $fcolor -NoNewLine

    moveCursor $currPos
}

function DrawMenu { param ([array]$menuItems, $menuPosition, $menuTitle)
    $fcolor = $host.UI.RawUI.ForegroundColor
    $bcolor = $host.UI.RawUI.BackgroundColor

    $menuwidth = $menuTitle.length + 4
    Write-Host "`t" -NoNewLine;    Write-Host ("=" * $menuwidth) -fore $fcolor -back $bcolor
    Write-Host "`t" -NoNewLine;    Write-Host " $menuTitel " -fore $fcolor -back $bcolor
    Write-Host "`t" -NoNewLine;    Write-Host ("=" * $menuwidth) -fore $fcolor -back $bcolor
    Write-Host ""
    for ($i = 0; $i -le $menuItems.length;$i++) {
        Write-Host "`t" -NoNewLine
        if ($i -eq $menuPosition) {
            Write-Host "$i. $($menuItems[$i])" -fore $bcolor -back $fcolor -NoNewline
            Write-Host "" -fore $fcolor -back $bcolor
        } else {
           if ($($menuItems[$i])) {
            Write-Host "$i. $($menuItems[$i])" -fore $fcolor -back $bcolor
           } 
        }
    }
    # leading new line
    Write-Host ""
}

function Menu { param ([array]$menuItems, $menuTitle = "MENU")
    $vkeycode = 0
    $pos = 0
    $oldPos = 0
    DrawMenu $menuItems $pos $menuTitle
    $currPos=$host.UI.RawUI.CursorPosition
    While ($vkeycode -ne 13) {
        $press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
        $vkeycode = $press.virtualkeycode
        Write-host "$($press.character)" -NoNewLine
        $oldPos=$pos;
        If ($vkeycode -eq 38) {$pos--}
        If ($vkeycode -eq 40) {$pos++}
        if ($pos -lt 0) {$pos = 0}
        if ($pos -ge $menuItems.length) {$pos = $menuItems.length -1}
        RedrawMenuItems $menuItems $oldPos $pos $currPos
    }
    Write-Output $pos
}

########################### by hapylestat menu routines END ######################






function Main-Menu {
    param (
        [string]$Title = 'Main Menu'
    )
    Write-Host "================ $Title ================"
    Write-Host "1: for Help"
    Write-Host "2: Install Options"
    Write-Host "3: Editor option"
    Write-Host "4: Show customized aliases"
    Write-Host "Q: quit"

    $selection = Read-Host "Please make a selection"
    switch ($selection) {
        '1' { psMenu-Help }
        '2' { psMenu-Install-Options }
        '3' { psMenu-Editor-Options }
        '4' { cat c:/users/mgua/psprofile/profile.ps1 | grep ^Set-Alias }
        'q' { return }  # Quit
    }
}

function psMenu-Help {
        Write-Host '================================================================== ' 
        Write-Host 'psprofile: a tool to manage powershell profile' 
        Write-Host '           see https://github.com/mgua/psprofile' 
        Write-Host ' ' 
        Write-Host 'Main commands:' 
        Write-Host '  pinstall: activates profile for next opened powershell' 
        Write-Host '  psmenu:   allows components installations'
        Write-Host '  pspe:     edit psprofile' 
        Write-Host ' ' 
        Write-Host 'Customizations:' 
        Write-Host '  See bottom part of the code in profile.ps1 to edit your aliases' 
        Write-Host '================================================================== ' 
}


function psMenu-Install-Options {
    param (
        [string]$Title = 'Install Options'
    )
    Write-Host "================ $Title ================"
    Write-Host "1: Upgrade PowerShell (winget)" 
    Write-Host "2: install NerdFonts (pwshell)"
    Write-Host "3: install/upgrade git (winget)"
    Write-Host "4: install/upgrade oh-my-posh (winget)"
    Write-Host "5: install/upgrade chocolatey (winget)"
    Write-Host "6: install/upgrade notepad++ (winget)"
    Write-Host "7: install/upgrade Microsoft vscode (winget)"
    Write-Host "8: install/upgrade neovim (winget)"
    Write-Host "="
    Write-Host "9: winget upgrade --all (possibly dangerous)"
    Write-Host "C: install chocolatey (pwshell)"
    Write-Host "T: choco install/upgrade bat curl fd fzf mingw make"
    Write-Host "U: upgrade psprofile (this tool) [possibly overwriting local mods]"
    Write-Host "W: install/upgrade wt Windows Terminal"
    Write-Host "X: install/upgrade wt Windows Terminal (ws2022)"
    Write-Host "="
    Write-Host "G: install/upgrade WINGET package installer (pwshell)"
    Write-Host "Q: to quit."

    $selection = Read-Host "Please make a selection"
    switch ($selection) {
        '1' { winget install Microsoft.Powershell }
        '2' { Install_HackNerdFonts }
        '3' { winget install git.git }
        '4' { winget install JanDeDobbeleer.OhMyPosh }
        '5' { winget install chocolatey.chocolatey }
        '6' { winget install notepad++.notepad++ }
        '7' { winget install vscode }
        '8' { winget install neovim.neovim }
	'9' { winget upgrade --all }
	'C' { Install_Chocolatey }
	'T' { choco install bat curl fd fzf mingw make }
	'U' { UpgradePsProfile }
	'W' { winget install --id Microsoft.WindowsTerminal }
	'X' { Install_WindowsTerminal_on_ws2022 }
	'G' { Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe }
        'q' { return }  # Quit
    }
}

function Install_HackNerdFonts {
	# another install option is choco install -y hack-nerd-font
	# Find-Module -name NerdFonts -AllVersions
	Install-Module -Name NerdFonts
	Import-Module -Name NerdFonts -DisableNameChecking
	# Install-Nerdfont -? to see all the available fonts
	#
	Install-NerdFont -Name Hack
}


function Install_Chocolatey {
	# from chocolatey.org website
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}


function Install_WindowsTerminal_on_ws2022 {
	# choco install microsoft.windows.terminal
	# from https://serverdecode.com/install-terminal-windows-server/
	#
	Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -outfile Microsoft.VCLibs.x86.14.00.Desktop.appx
 	Import-Module appx
	# Add-AppxPackage Microsoft.VCLibs.x86.14.00.Desktop.appx
	Invoke-WebRequest -Uri https://github.com/microsoft/terminal/releases/download/v1.18.3181.0/Microsoft.WindowsTerminal_1.18.3181.0_8wekyb3d8bbwe.msixbundle_Windows10_PreinstallKit.zip -outfile Microsoft.WindowsTerminal_1.18.3181.0_8wekyb3d8bbwe.msixbundle_Windows10_PreinstallKit.zip
 	# from inside this zip, the x64 preinstall object has to be installed with add-appxpackage
  	Add-AppxPackage Microsoft.UI.Xaml.2.8_8.2310.30001.0_x64__8wekyb3d8bbwe.appx
   	# then we download the actual terminal app
	Invoke-WebRequest -Uri https://github.com/microsoft/terminal/releases/download/v1.18.3181.0/Microsoft.WindowsTerminal_1.18.3181.0_8wekyb3d8bbwe.msixbundle -outfile Microsoft.WindowsTerminal_1.18.3181.0_8wekyb3d8bbwe.msixbundle
 	#not ok. sorry
	Add-AppxPackage Microsoft.WindowsTerminal_1.18.3181.0_8wekyb3d8bbwe.msixbundle
}


function psMenu-Editor-Options {
    param (
        [string]$Title = 'Install Options'
    )
    Write-Host "================ $Title ================"
    Write-Host "1: customize vscode"
    Write-Host "2: customize notepad++"
    Write-Host "3: customize neovim (mgua kickstart)"
    Write-Host "Q: to quit."

    $selection = Read-Host "Please make a selection"
    switch ($selection) {
        '1' { 
	      Write-Host "see https://code.visualstudio.com/docs/getstarted/settings" 
              Write-Host "you can sync your vscode settings to your github account" 
	    }
        '2' { 
	      Write-Host "see https://www.npp-user-manual.org/docs/preferences/#style-configurator" 
              Write-Host "default per user configs go in %AppData%\notepad++"
	    }
        '3' { 
	      Write-Host "cd ~/AppData/local/nvim"
	      git pull "https://marco.guardigli/kickstart.git"
	      nvim
	      }
        'q' { return }  # Quit
    }
}


function UpgradePsProfile {
	# upgrade this tool, downloading new version in current folder, via git
	# we expect that the folder from which the command is run is the one where the initial
	# git clone was performed
	# CAUTION. this overwrites local changes
	Write-Host "UpgradePsProfile: to be run from folder where psprofile was git-cloned"
	Write-Host "                  CAUTION: git pull may overwrite local changes not committed"
	pause "Press ENTER to continue, or CTRL-C to cancel"
	git add .
	git pull 
	. .\profile.ps1
	& pinstall
}


function Profile-Install {
	# this file will have to be appended to the existing $PROFILE file
	#
	$currentFolder = Get-Location
	$newProfile = Join-Path $currentFolder "profile.ps1"
	if (Test-Path $newProfile) {
		Write-Host "newProfile found: [$newProfile]"
		if (Test-Path $PROFILE) {
			Write-Host "PROFILE: [$PROFILE] exists"
		} else {
			New-Item -ItemType File -Path $PROFILE -Force
			Write-Host "PROFILE: [$PROFILE] created"
		}
		# $thisScriptName = $MyInvocation.MyCommand.Name
		#$thisScriptPath = $PSScriptRoot
		#$thisScriptFullName = Join-Path $thisScriptPath $thisScriptName
		Write-Host "copy/append newProfile to PROFILE: executing profile copy..."
		Write-Host "  copy `"$newProfile`" `"$PROFILE`""
		copy "$newProfile" "$PROFILE"
		Write-Host "done."
	} else {
		Write-Host "newProfile not found: [$newProfile]"
		Write-Host "currentFolder: [$currentFolder] expected newProfile: [$newProfile]"
		Write-Host "Error: you need to execute this command from the folder where you downloaded it"
	}
}

function Get-ExecutablePath {
	# given an executable name, finds the full path
	# you can also use where.exe executablename
	# (this was generated by bing)
    param (
        [Parameter(Mandatory=$true)]
        [string]$ExecutableName
    )
    $path = Get-Command $ExecutableName | Select-Object -ExpandProperty Path
    return $path
}



# the following snippet comes from bing codepilot
# 
# $env_path = "C:\path\to\env"
# $command = "python my_script.py"
# $activate_script = "$env_path\Scripts\activate.ps1"
# 
# Start-Process powershell -ArgumentList "-NoExit", "-Command", "& '$activate_script'; $command"
# 


function Launch-Nvim {
	# nvim executable can be in different locations
	# and we want to run it possibly in windows terminal
	#	$command = "`"c:\program files\Neovim\bin\nvim.exe`""
	#	$command = "`"c:\Users\mguardigli\AppData\Local\Programs\Neovim\bin\nvim.exe`""
	#$mycmd = "`"nvim`"" (this quoting suddenly stopped working)on 12 oct 2023)
	$mycmd = "nvim"
	$cmd = where.exe $mycmd
	# if available, run in windows terminal (wt), else cmd
	# this horror code appears needed to avoid launching a not wt window
	if ( Get-Command "wt" -ErrorAction SilentlyContinue ) {
		$command = "wt"
		$cargs = "$cmd $args"
	} else {
		$command = "cmd"
		$cargs = "/c $cmd $args"
		# cmd /c c:\nvimpath\nvim.exe $args
	}
	Write-Host "command: [$command] cargs: [$cargs]"
	$parameters = $cargs -join ' '
	if ($parameters) {
		# BEWARE using -NoNewWindow option causes terminal to malfunction
		Start-Process -FilePath $command -ArgumentList $parameters
	} else {
		Start-Process -FilePath $command
	}
}

function Launch-NotepadPlusPlus {
	$command = "`"c:\program files\notepad++\notepad++.exe`""
	$parameters = $args -join ' '
		if ($parameters) {
			Start-Process -FilePath $command -ArgumentList $parameters
		} else {
			Start-Process -FilePath $command
		}
}


function Launch-Explorer {
	$command = "`"c:\windows\explorer.exe`""
	$parameters = $args -join ' '
		if ($parameters) {
			Start-Process -FilePath $command -ArgumentList $parameters
		} else {
			# if no parameters are passed open current folder
			Start-Process -FilePath $command -ArgumentList "."
		}
}

function Launch-MidnightCommander {
	$command = "`"C:\Program Files (x86)\Midnight Commander\mc.exe`""
	$parameters = $args -join ' '
		if ($parameters) {
			Start-Process -FilePath $command -ArgumentList $parameters
		} else {
			# if no parameters are passed open current folder
			Start-Process -FilePath $command -ArgumentList "."
		}
}


function Admin-Edit-Hosts {
	# edit c:\windows\system32\drivers\etc\hosts from admin mode
	$command = "`"c:\program files\notepad++\notepad++.exe`""
	$parameters = "c:\windows\system32\drivers\etc\hosts" -join ' '
	Write-Host "Admin-Edit-Hosts: [$command] [$parameters]"
	#Start-Process -FilePath $command -ArgumentList "c:\windows\system32\drivers\etc\hosts" -Verb RunAs
	Start-Process -FilePath $command -ArgumentList $parameters -Verb RunAs 
}

function Admin-Run-HostEdit {
	# see https://github.com/mgua/hostedit
	$command = "powershell"
	$parameters = "c:\windows\system32\drivers\etc\hostedit.ps1" -join ' '
	Write-Host "Admin-Run-HostEdit: [$command] [$parameters] (see https://github.com/mgua/hostedit )"
	Start-Process -FilePath $command -ArgumentList $parameters -Verb RunAs 
}

function Alias-cdh {
	# cd to home directory
	Set-Location -Path $env:USERPROFILE
} 

function ProfileEdit {
	& notepad.exe $profile
}

function lsll {
	& Get-ChildItem 
}

function psProfileEdit {
	# poweshell profile edit: allow editing this file and update
	Set-Location -Path $env:USERPROFILE"\psprofile"
	& nvim profile.ps1
	Write-Host "when editing is done, run pinstall from this folder and execute the suggested copy command"
	Write-Host '"consider executing "git add ." , "git commit -m..." and "git push" to update the repos'
	Write-Host 'run ". .\profile.ps1" to activate the new aliases in the current session'
}

function DeactivateEnvironment {
    # Check for common environment managers
    if ($env:VIRTUAL_ENV) {
        Write-Host "Virtual environment is active: $($env:VIRTUAL_ENV)"
        if ($env:CONDA_PREFIX) {
            # Write-Host "Deactivating conda environment..."
            conda deactivate
        } else {
            # Write-Host "Deactivating venv/virtualenv..."
            deactivate
        }
    } else {
        Write-Host "No supported environment manager detected: Assuming no environment is active."
        return
    }
}


function Select-VirtualEnvironment {
    # list folders with *venv* in their name and allow to choose one switching to it
    $venvFolders = Get-ChildItem -Directory -Filter "*venv*"
    if ($venvFolders.Count -eq 0) {
        Write-Host "No folders found with 'venv' in the name."
        return
    }
    $myvenv = Menu $venvFolders "Select venv"
    $myvenvdir = $venvFolders[$myvenv]
    # Write-Host "You Selected $myvenv : $myvenvdir"
    $activatecmd = "$($myvenvdir)\Scripts\Activate.ps1"
    DeactivateEnvironment
    # Write-Host "activating venv environment with cmd = [$activatecmd]"
    & $activatecmd
    Write-Host "VIRTUAL_ENV = [$env:VIRTUAL_ENV]"
}


function Get-FolderSize {
    param(
        [string]$Path
    )
    $size = Get-ChildItem $Path -Recurse | Measure-Object -Property Length -Sum
    $sizeInBytes = $size.Sum
    # Convert bytes to megabytes for better readability
    $sizeInMB = $sizeInBytes / 1MB
    # Write-Host "Total size of '$Path': $($sizeInMB:F2) MB"
    return $sizeInMB
}


function ListVenvFolders {
    # list folders with *venv* in their name and show disk size
    $venvFolders = Get-ChildItem -Directory -Filter "*venv*"
    if ($venvFolders.Count -eq 0) {
        Write-Host "No folders found with 'venv' in the name."
       return
    }
    foreach ($venvf in $venvFolders) { 
        $fsize = Get-FolderSize -Path $venvf.Fullname
        $fsize_approx = "{0:N0}"  -f $fsize
        Write-Host "$($venvf.Name):`t`t $fsize_approx" 
    }
}


function Get-FileSizeString {
    # this is used in lla alias
    # mgua 2024 08 16 (thanks gemini)
    param(
        [int64]$sizeInBytes
    )

    $sizeKB = $sizeInBytes / 1KB
    $sizeMB = $sizeKB / 1024
    $sizeGB = $sizeMB / 1024

    if ($sizeGB -ge 1) {
        return "{0:N2} GB" -f $sizeGB
    } elseif ($sizeMB -ge 1) {
        return "{0:N2} MB" -f $sizeMB
    } else {
        return "{0:N0} KB" -f $sizeKB
    }
}


function Alias-lla {
    # mgua aug 16 2024
    Get-ChildItem -Force | Format-Table -AutoSize Name, @{Name="LastWriteTime";Expression={$_.LastWriteTime.ToString("yyyy/MM/dd HH:mm:ss")}}, @{Name="Size";Expression={Get-FileSizeString $_.Length}}, @{Name="Mode";Expression={$_.Mode}}
}



Set-Alias -Name pinstall -Value Profile-Install -Description "Get Install Instructions"
Set-Alias -Name la -Value Get-Alias -Description "List command Aliases defined in Powershell"
Set-Alias -Name ga -Value Get-Alias -Description "List command Aliases defined in Powershell"
Set-Alias -Name hed -Value Admin-Edit-Hosts -Description "Edit hosts file in admin mode"
Set-Alias -Name her -Value Admin-Run-HostEdit -Description "Launch hostedit in admin mode"
Set-Alias -Name vi -Value Launch-Nvim -Description "Launch neovim"
Set-Alias -Name vim -Value Launch-Nvim -Description "Launch neovim"
Set-Alias -Name nvim -Value Launch-Nvim -Description "Launch neovim"
Set-Alias -Name mc -Value Launch-MidnightCommander -Description "Launch GNU Midnight Commander"
Set-Alias -Name npp -Value Launch-NotepadPlusPlus -Description "Launch Notepad++"
Set-Alias -Name np -Value Launch-NotepadPlusPlus -Description "Launch Notepad++"
Set-Alias -Name ex -Value Launch-Explorer
#Set-Alias -Name cdh -Value Alias-cdh -Description "Alias cdh: go to current user home directory"
Set-Alias -Name cdh -Value Alias-cdh -Description "cd to current user home folder" 
Set-Alias -Name ll -Value lsll -Description " dir "
Set-Alias -Name lv -Value "ListVenvFolders" -Description "show venv folders and related sizes"
Set-Alias -Name pspe -Value psProfileEdit -Description "edit the powershell profile"
Set-Alias -Name psmenu -Value Main-Menu -Description "show Main Menu"
Set-Alias -Name se -Value Select-VirtualEnvironment -Description "choose & activate *venv*"
Set-Alias -Name lla -Value Alias-lla -Description "shows file size in suitable units like ls -lah"


# the following line invokes oh-my-posh
# see https://ohmyposh.dev/
# would be nice to perform installation of omp via a initial config menu thru which several
# ancillary packets could be added
oh-my-posh init pwsh | Invoke-Expression
Write-Host 'psprofile: Powershell profile manager. psmenu for help. See: https://github.com/mgua/psprofile'


