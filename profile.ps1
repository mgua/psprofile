# this is my powershell alias file
# mgua@tomware.it
# october-november 2023
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

function Main-Menu {
    param (
        [string]$Title = 'Main Menu'
    )
    Write-Host "================ $Title ================"
    Write-Host "1: Press '1' for Help"
    Write-Host "2: Press '2' for Install Options"
    Write-Host "3: Press '3' for Editor option"
    Write-Host "="
    Write-Host "4: Press '4' to install Hack Nerd Font"
    Write-Host "5: Press '5' for option 5"
    Write-Host "Q: Press 'Q' to quit."

    $selection = Read-Host "Please make a selection"
    switch ($selection) {
        '1' { psMenu-Help }
        '2' { psMenu-Install-Options }
        '3' { psMenu-Editor-Options }
        'q' { return }  # Quit
    }
}

function psMenu-Help {
        Write-Host 'You chose Help' 
}


function psMenu-Install-Options {
    param (
        [string]$Title = 'Install Options'
    )
    Write-Host "================ $Title ================"
    Write-Host "1: Upgrade PowerShell"
    Write-Host "2: install NerdFonts"
    Write-Host "3: install/upgrade git"
    Write-Host "4: install/upgrade oh-my-posh"
    Write-Host "5: install/upgrade chocolatey"
    Write-Host "6: install/upgrade notepad++"
    Write-Host "7: install/upgrade Microsoft vscode"
    Write-Host "8: install/upgrade neovim"
    Write-Host "="
    Write-Host "9: winget upgrade --all"
    Write-Host "T: choco install/upgrade bat curl fd fzf mingw make"
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
	'T' { choco install bat curl fd fzf mingw make }
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


function psMenu-Editor-Options {
        Write-Host 'You chose Editor Options' 
	Write-Host '# check if notepad++ is installed # check if vscode is installed # check if neovim is installed'
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
		Write-Host "copy/append newProfile to PROFILE: execute this to activate"
		Write-Host "  copy `"$newProfile`" `"$PROFILE`""
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

Set-Alias -Name pinstall -Value Profile-Install -Description "Get Install Instructions"
Set-Alias -Name hed -Value Admin-Edit-Hosts -Description "Edit hosts file in admin mode"
Set-Alias -Name her -Value Admin-Run-HostEdit -Description "Launch hostedit in admin mode"
Set-Alias -Name vi -Value Launch-Nvim -Description "Launch neovim"
Set-Alias -Name vim -Value Launch-Nvim -Description "Launch neovim"
Set-Alias -Name nvim -Value Launch-Nvim -Description "Launch neovim"
Set-Alias -Name npp -Value Launch-NotepadPlusPlus
Set-Alias -Name np -Value Launch-NotepadPlusPlus
#Set-Alias -Name cdh -Value Alias-cdh -Description "Alias cdh: go to current user home directory"
Set-Alias -Name cdh -Value Alias-cdh -Description "cd to current user home folder" 
Set-Alias -Name ll -Value lsll -Description " dir "
Set-Alias -Name pspe -Value psProfileEdit -Description "edit the powershell profile"
Set-Alias -Name psmenu -Value Main-Menu -Description "show Main Menu"

# the following line invokes oh-my-posh
# see https://ohmyposh.dev/
oh-my-posh init pwsh | Invoke-Expression
Write-Host 'psprofile: Powershell profile manager. psmenu for help. See: https://github.com/mgua/psprofile'


