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
#	add secd alias to choose environment and change current folder to project folder
#
# jan 20 2025: mgua
#	chenged default oh-my-posh prompt to have python environment correctly shown
#	(switchd to slimfat theme)
#
# jul 17 2025: mgua
# 	added support for cygwin launch within powershell session. this allows to run posix
# 	commands within the same CLI, with lots of flexibility
# 	(alias is cyg)
#
# 	update midnight commander default path for 64bit version *not x86*
#
# dec 26 2025: mgua
#	improved nvim invocation with two approaches:
#	  1. Launch-NvimLocal: runs in current shell, preserves venv/PATH, works over SSH
#	     (aliases: nv, nvim, vi, vim)
#	  2. Launch-NvimNew: opens in new window/tab for clean environment
#	     (aliases: nvim-new, nv-new)
#	proper argument forwarding using @Arguments for all nvim options
#	
#	because of an error in the env variable $env:POSH_THEMES_PATH, we resorted to
#	recommend to clone the whole oh-my-posh repo in the user home folder
#		mkdir c:\Users\<user>\oh-my-posh
#		cd c:\Users\<user>\oh-my-posh
#		git clone https://github.com/JanDeDobbeleer/oh-my-posh.git .
#
# jan 07 2026: mgua
#	improved Launch-MidnightCommander: if mc.exe not found, fallback to far.exe
#	both mc and far now launch in the current working directory
#
# jan 14 2026: starting to add chezmoi integrations
#		chezdiff: chezdiff <file> 
#	edits with neovim the local dotfile showing differences with
#	chezmoi repo version
#
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
# 	If you still get error you may need to execute 
#	Unblock-File -Path .\profile.ps1
#	from the <user>\psprofile folder
#
# to fix readline errors, execute the following as admin
# Install-Module -Name PSReadLine -Force -SkipPublisherCheck
# see https://github.com/JanDeDobbeleer/oh-my-posh/issues/7152
#
# see https://stackoverflow.com/questions/24914589/how-to-create-permanent-powershell-aliases
#
# check last access time of a folder/file
# Get-ChildItem | Where-Object {$_.psiscontainer} | ForEach-Object {"{0}`t{1}" -f $_.name,$_.lastaccesstime}
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


function Launch-NvimLocal {
	# Launch nvim in the current shell context
	# This preserves Python venv, environment variables, and works over SSH
	# mgua - jan 2026
	
	param(
		[Parameter(ValueFromRemainingArguments=$true)]
		[string[]]$Arguments
	)
	
	# Get the actual nvim EXECUTABLE, not any alias
	$nvimCmd = Get-Command nvim -CommandType Application -ErrorAction SilentlyContinue
	
	if (-not $nvimCmd) {
		Write-Host "Error: nvim executable not found in PATH" -ForegroundColor Red
		return
	}
	
	# Store the path and execute
	$nvimPath = $nvimCmd.Path
	& $nvimPath @Arguments
}


function Launch-NvimNew {
	# Launch nvim in a new shell/window
	# Useful for clean environment, but won't work over SSH
	# mgua - jan 2026
	
	param(
		[Parameter(ValueFromRemainingArguments=$true)]
		[string[]]$Arguments
	)
	
	# Check if we're in an SSH session
	if ($env:SSH_CLIENT -or $env:SSH_CONNECTION -or $env:SSH_TTY) {
		Write-Host "Warning: SSH session detected. Cannot open new window." -ForegroundColor Yellow
		Write-Host "         Falling back to local invocation (use 'nv' or 'nvim' for SSH)." -ForegroundColor Yellow
		Write-Host ""
		# Fall back to local invocation
		Launch-NvimLocal @Arguments
		return
	}
	
	# Get the actual nvim EXECUTABLE, not any alias
	$nvimCmd = Get-Command nvim -CommandType Application -ErrorAction SilentlyContinue
	
	if (-not $nvimCmd) {
		Write-Host "Error: nvim executable not found in PATH" -ForegroundColor Red
		return
	}
	
	$nvimPath = $nvimCmd.Path
	
	# Properly escape and quote arguments for passing to new shell
	$escapedArgs = @()
	foreach ($arg in $Arguments) {
		if ($arg -match '[\s"'']') {
			$escaped = $arg -replace '"', '`"'
			$escapedArgs += "`"$escaped`""
		} else {
			$escapedArgs += $arg
		}
	}
	$argString = $escapedArgs -join ' '
	
	# Try Windows Terminal first (if available)
	if (Get-Command wt.exe -ErrorAction SilentlyContinue) {
		Write-Host "Launching nvim in new Windows Terminal tab..." -ForegroundColor Green
		Start-Process wt.exe -ArgumentList "-w 0 nt pwsh.exe -NoExit -Command `"& '$nvimPath' $argString`""
	} 
	# Fall back to new PowerShell window
	else {
		Write-Host "Launching nvim in new PowerShell window..." -ForegroundColor Green
		$command = "& '$nvimPath' $argString"
		Start-Process pwsh.exe -ArgumentList "-NoExit -Command `"$command`""
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

function Launch-CygwinBash {
	$command = "`"c:\cygwin64\bin\bash`""
	$parameters = "-l" -join ' '
		if ($parameters) {
			Start-Process -FilePath $command -ArgumentList $parameters -NoNewWindow -Wait
		} else {
			# if no parameters are passed open current folder
			Start-Process -FilePath $command -ArgumentList "." -NoNewWindow -Wait
		}
}



function Launch-MidnightCommander {
	# jan 07 2026: mgua
	# improved to fallback to FAR Manager if mc.exe is not available
	# both mc and far now launch in the current working directory
	
	# Define possible paths for Midnight Commander
	$mcPaths = @(
		"C:\Program Files\Midnight Commander\mc.exe",
		"C:\Program Files (x86)\Midnight Commander\mc.exe"
	)
	
	# Define possible paths for FAR Manager
	$farPaths = @(
		"C:\Program Files\Far Manager\far.exe",
		"C:\Program Files (x86)\Far Manager\far.exe"
	)
	
	# Get current working directory
	$workingDir = (Get-Location).Path
	
	# Try to find mc.exe
	$mcExe = $null
	foreach ($path in $mcPaths) {
		if (Test-Path $path) {
			$mcExe = $path
			break
		}
	}
	
	# Also check if mc is in PATH
	if (-not $mcExe) {
		$mcCmd = Get-Command mc.exe -ErrorAction SilentlyContinue
		if ($mcCmd) {
			$mcExe = $mcCmd.Path
		}
	}
	
	# If mc found, use it
	if ($mcExe) {
		$parameters = $args -join ' '
		if ($parameters) {
			Start-Process -FilePath $mcExe -ArgumentList $parameters -WorkingDirectory $workingDir -NoNewWindow -Wait
		} else {
			Start-Process -FilePath $mcExe -WorkingDirectory $workingDir -NoNewWindow -Wait
		}
		return
	}
	
	# mc not found, try FAR Manager
	$farExe = $null
	foreach ($path in $farPaths) {
		if (Test-Path $path) {
			$farExe = $path
			break
		}
	}
	
	# Also check if far is in PATH
	if (-not $farExe) {
		$farCmd = Get-Command far.exe -ErrorAction SilentlyContinue
		if ($farCmd) {
			$farExe = $farCmd.Path
		}
	}
	
	# If FAR found, use it
	if ($farExe) {
		Write-Host "mc.exe not found, using FAR Manager instead" -ForegroundColor Yellow
		$parameters = $args -join ' '
		if ($parameters) {
			Start-Process -FilePath $farExe -ArgumentList $parameters -WorkingDirectory $workingDir -NoNewWindow -Wait
		} else {
			Start-Process -FilePath $farExe -WorkingDirectory $workingDir -NoNewWindow -Wait
		}
		return
	}
	
	# Neither found
	Write-Host "Error: Neither Midnight Commander (mc.exe) nor FAR Manager (far.exe) found." -ForegroundColor Red
	Write-Host "Install mc with: choco install mc" -ForegroundColor Yellow
	Write-Host "Install FAR with: choco install far" -ForegroundColor Yellow
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


function psProfileEdit {
	param()
	notepad.exe "$PROFILE"
}

# chezmoi integrations BEGIN ##################################################

function chezdiff {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    $sourcePath = chezmoi source-path $Path
    nvim -d $Path $sourcePath
}

# chezmoi integrations END  ###################################################



function Alias-cdh {
    Set-Location -Path $env:USERPROFILE 
    Get-Location
}


function lsll {
   dir -Force
}


function Select-VirtualEnvironment {
    # Function to select and activate a Python virtual environment
    # Lists *venv* folders in the user's home directory
    # Uses the built-in Menu function for selection
    # Activates the selected environment

    # Find *venv* folders in user home directory
    $venvFolders = @(Get-ChildItem -Path $env:USERPROFILE -Directory -Filter "*venv*" | Select-Object -ExpandProperty Name)

    if ($venvFolders.Count -eq 0) {
        Write-Host "No virtual environment folders found in $env:USERPROFILE" -ForegroundColor Yellow
        return
    }

    # Use the Menu function for selection
    Write-Host ""
    Write-Host "Virtual Environments in $env:USERPROFILE" -ForegroundColor Cyan
    $selection = Menu $venvFolders "Select Environment"

    # Get the selected folder name
    $selectedEnv = $venvFolders[$selection]
    $activateScript = Join-Path $env:USERPROFILE $selectedEnv "Scripts\Activate.ps1"

    if (Test-Path $activateScript) {
        # Deactivate current environment if one is active
        if ($env:VIRTUAL_ENV) {
            Write-Host "Deactivating current environment: $env:VIRTUAL_ENV" -ForegroundColor Yellow
            deactivate
        }
        
        Write-Host "Activating: $selectedEnv" -ForegroundColor Green
        & $activateScript
    } else {
        Write-Host "Activate script not found at: $activateScript" -ForegroundColor Red
    }
}


function Select-VirtualEnvironmentCd {
    # Function to select and activate a Python virtual environment
    # Lists venv_* folders in the user's home directory
    # Uses the built-in Menu function for selection
    # Activates the selected environment
    # changes current folder to the project folder if present

    # Find venv_* folders in user home directory (venv_prjname<N>)
    $venvFolders = @(Get-ChildItem -Path $env:USERPROFILE -Directory -Filter "venv_*" | Select-Object -ExpandProperty Name)

    if ($venvFolders.Count -eq 0) {
        Write-Host "No virtual environment (venv_*) folders found in $env:USERPROFILE" -ForegroundColor Yellow
        return
    }

    # Use the Menu function for selection
    Write-Host ""
    Write-Host "Virtual Environments venv_* in $env:USERPROFILE" -ForegroundColor Cyan
    $selection = Menu $venvFolders "Select Environment"

    # Get the selected folder name (venv_<envname>)
    $selectedEnv = $venvFolders[$selection]
    $activateScript = Join-Path $env:USERPROFILE $selectedEnv "Scripts\Activate.ps1"
    $projFolder = $selectedEnv -replace 'venv_', ''
    $projFolderPath = Join-Path $env:USERPROFILE "prj" $projFolder

    if (Test-Path $activateScript) {
        # Deactivate current environment if one is active
        if ($env:VIRTUAL_ENV) {
            Write-Host "Deactivating current environment: $env:VIRTUAL_ENV" -ForegroundColor Yellow
            deactivate
        }
        
        Write-Host "Activating: $selectedEnv" -ForegroundColor Green
        & $activateScript
    } else {
        Write-Host "Activate script not found at: $activateScript" -ForegroundColor Red
    }
    if (Test-Path $projFolderPath) {
        Write-Host "Going to Project Folder: $projFolderPath" -ForegroundColor Green
        Set-Location -Path $projFolderPath 
        Get-Location
    } else {
        Write-Host "Project Folder not found: $projFolderPath" -ForegroundColor Red
    }
    
}

function ListVenvFolders {
    param (
        [string]$Path = $env:USERPROFILE
    )

    # Get all directories matching *venv* at the specified path
    $venvFolders = Get-ChildItem -Path $Path -Directory -Filter "*venv*" -ErrorAction SilentlyContinue

    if (-not $venvFolders) {
        Write-Host "No directories matching '*venv*' found at path: $Path"
        return
    }

    foreach ($folder in $venvFolders) {
        # Calculate the size of the folder
        $folderSize = (Get-ChildItem -Path $folder.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum

        # Convert size to a human-readable format
        $sizeInMB = "{0:N2} MB" -f ($folderSize / 1MB)
        $sizeInGB = "{0:N2} GB" -f ($folderSize / 1GB)

        # Display the folder name and its size
        if ($folderSize -ge 1GB) {
            Write-Host "$($folder.Name): $sizeInGB"
        } else {
            Write-Host "$($folder.Name): $sizeInMB"
        }
    }
}


# Function to get file size in human-readable format
function Get-FileSizeString {
    param (
        [long]$sizeInBytes
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


function Get-LinuxLs {
    param (
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )
    
    # Initialize default parameters
    $showHidden = $false
    $detailed = $false
    $humanReadable = $false
    
    # Parse arguments if present
    if ($Arguments) {
        foreach ($arg in $Arguments) {
            # Handle combined or separate flags
            if ($arg -match '^-') {
                if ($arg -match 'l') { $detailed = $true }
                if ($arg -match 'a') { $showHidden = $true }
                if ($arg -match 'h') { $humanReadable = $true }
            }
        }
    }
    
    # Function to convert size to human readable format
    function Format-FileSize {
        param ([long]$size)
        $suffix = "B", "K", "M", "G", "T", "P", "E"
        $index = 0
        while ($size -gt 1024 -and $index -lt ($suffix.Count - 1)) {
            $size = $size / 1024
            $index++
        }
        
        # Format with proper rounding
        if ($index -eq 0) {
            return "{0,6}B" -f $size # Bytes don't need decimal places
        }
        else {
            return "{0,5:N1}{1}" -f $size, $suffix[$index]
        }
    }
    
    # Build Get-ChildItem parameters
    $params = @{}
    if ($showHidden) {
        $params.Force = $true  # Show hidden files
    }
    
    # Get items
    $items = Get-ChildItem @params
    
    # Display items
    if ($detailed) {
        $items | ForEach-Object {
            # Create Linux-style permission string
            $mode = switch ($_.Mode) {
                'd*' { 'd' }
                default { '-' }
            }
            $mode += if ($_.Mode -match 'r') {'r'} else {'-'}
            $mode += if ($_.Mode -match 'w') {'w'} else {'-'}
            $mode += if ($_.Mode -match 'x') {'x'} else {'-'}
            $mode += '------'  # Group and Others permissions (simplified)
            
            # Format size based on -h flag
            $size = if ($humanReadable) {
                Format-FileSize $_.Length
            }
            else {
                "{0,10}" -f $_.Length
            }
            
            # Format last write time
            $time = $_.LastWriteTime.ToString("MMM dd HH:mm")
            
            # Output in ls -l format
            "{0}  1 {1}  {2} {3}  {4} {5}" -f $mode, 
                                             $_.Owner, 
                                             $_.Group, 
                                             $size, 
                                             $time, 
                                             $_.Name
        }
    }
    else {
        # Simple listing
        $items | Select-Object -ExpandProperty Name
    }
}


function Set-AliasSafe {
    # Helper function to safely set aliases, handling AllScope and ReadOnly options
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [string]$Value,
        [string]$Description = ""
    )
    
    # Check if alias already exists
    $existingAlias = Get-Alias -Name $Name -ErrorAction SilentlyContinue
    
    if ($existingAlias) {
        # Check if it has AllScope option
        if ($existingAlias.Options -match 'AllScope') {
            # Must preserve AllScope when redefining
            Set-Alias -Name $Name -Value $Value -Description $Description -Option AllScope -Force -Scope Global
        } else {
            # Normal alias, just force override
            Set-Alias -Name $Name -Value $Value -Description $Description -Force
        }
    } else {
        # New alias, set normally
        Set-Alias -Name $Name -Value $Value -Description $Description
    }
}


function Get-GitStatus {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $args
    )
    git status $args
}


Set-Alias -Name pinstall -Value Profile-Install -Description "Get Install Instructions"
Set-Alias -Name la -Value Get-Alias -Description "List command Aliases defined in Powershell"
Set-Alias -Name ga -Value Get-Alias -Description "List command Aliases defined in Powershell"
Set-Alias -Name hed -Value Admin-Edit-Hosts -Description "Edit hosts file in admin mode"
Set-Alias -Name her -Value Admin-Run-HostEdit -Description "Launch hostedit in admin mode"
# Local nvim invocation (preserves context, works over SSH) - using Set-AliasSafe to handle AllScope
Set-AliasSafe -Name vi -Value Launch-NvimLocal -Description "Launch neovim locally (preserves context)"
Set-AliasSafe -Name vim -Value Launch-NvimLocal -Description "Launch neovim locally (preserves context)"
Set-AliasSafe -Name nvim -Value Launch-NvimLocal -Description "Launch neovim locally (preserves context)"
Set-AliasSafe -Name nv -Value Launch-NvimLocal -Description "Launch neovim locally (preserves context)"
# New window nvim invocation (clean environment, won't work over SSH)
Set-AliasSafe -Name nvim-new -Value Launch-NvimNew -Description "Launch neovim in new window/tab"
Set-AliasSafe -Name nv-new -Value Launch-NvimNew -Description "Launch neovim in new window/tab"
Set-Alias -Name mc -Value Launch-MidnightCommander -Description "Launch GNU Midnight Commander (fallback: FAR Manager)"
Set-Alias -Name npp -Value Launch-NotepadPlusPlus -Description "Launch Notepad++"
Set-Alias -Name np -Value Launch-NotepadPlusPlus -Description "Launch Notepad++"
Set-Alias -Name ex -Value Launch-Explorer

Set-Alias -Name cyg -Value Launch-CygwinBash -Description "Launch Cygwin BASH from c:/cygwin64/bin/bash"

#Set-Alias -Name cdh -Value Alias-cdh -Description "Alias cdh: go to current user home directory"
Set-Alias -Name cdh -Value Alias-cdh -Description "cd to current user home folder" 
Set-Alias -Name ll -Value lsll -Description " dir "
Set-Alias -Name lv -Value "ListVenvFolders" -Description "show venv folders and related sizes"
Set-Alias -Name pspe -Value psProfileEdit -Description "edit the powershell profile"
Set-Alias -Name psmenu -Value Main-Menu -Description "show Main Menu"
Set-Alias -Name se -Value Select-VirtualEnvironment -Description "choose & activate *venv*"
Set-Alias -Name secd -Value Select-VirtualEnvironmentCd -Description "choose & activate venv_* and cd to prj folder"
Set-Alias -Name lla -Value Alias-lla -Description "shows file size in suitable units like ls -lah"

Set-Alias -Name ls -Value Get-LinuxLs -Option AllScope -Description "emulates *nix ls [-l -a -h]"

Set-Alias -Name gst -Value Get-GitStatus -Option AllScope -Description "shortcut for git status [-s]"

Set-Alias -Name cmdiff -Value chezdiff -Description "Edit specific file diffing w/chezmoi version"


# the following line invokes oh-my-posh
# see https://ohmyposh.dev/
# would be nice to perform installation of omp via a initial config menu thru which several
# ancillary packets could be added
#
# oh-my-posh init pwsh | Invoke-Expression
# & ([ScriptBlock]::Create((oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" --print) -join "`n"))
& ([ScriptBlock]::Create((oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\slimfat.omp.json" --print) -join "`n"))
# C:\Users\<user>\AppData\Local\Programs\oh-my-posh\themes\
# "$env:USERPROFILE\AppData\Local\Programs\oh-my-posh\themes\slimfat.omp.json"
# & ([ScriptBlock]::Create((oh-my-posh init pwsh --config "$env:USERPROFILE\AppData\Local\Programs\oh-my-posh\themes\slimfat.omp.json" --print) -join "`n"))
#
# we assume that oh-my-posh has been cloned in ~/oh-my-posh/ from https://github.com/JanDeDobbeleer/oh-my-posh.git
# & ([ScriptBlock]::Create((oh-my-posh init pwsh --config "$env:USERPROFILE\oh-my-posh\themes\slimfat.omp.json" --print) -join "`n"))
#
Write-Host 'psprofile: Powershell profile manager. psmenu for help. See: https://github.com/mgua/psprofile'

# as of jan 17 2025 the posh themes supporting 
#	the python environment
#	the git branch
#	the local path
#
#	are:
#		tonybaloney
#		space
#		smothie
#		rudolfs-dark
#		rudolfs-light
#		powerlevel10k_modern
#		poshmon
#		slim
#		slimfat		(slimfat.omp.json)
#
