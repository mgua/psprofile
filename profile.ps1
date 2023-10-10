# this is my powershell alias file
# mgua@tomware.it
# october 2023
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
		Write-Host "copy/append newProfile to PROFILE:"
		Write-Host "  copy `"$newProfile`" `"$PROFILE`""
	} else {
		Write-Host "newProfile not found: [$newProfile]"
		Write-Host "currentFolder: [$currentFolder] expected newProfile: [$newProfile]"
		Write-Host "Error: you need to execute this command from the folder where you downloaded it"
	}
}


function Launch-Nvim {
	$command = "`"c:\program files\Neovim\bin\nvim.exe`""
	$parameters = $args -join ' '
		if ($parameters) {
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




