# this is my powershell alias file
# mgua@tomware.it
# october 2023
#
# save it in C:\Users\<username>\Documents\profile.ps1 
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

function Launch-Nvim {
	& nvim.exe
}

function Launch-NotepadPlusPlus {
	& "c:\program files\notepad++\notepad++.exe"
}

function Admin-Edit-Hosts {
	# edit c:\windows\system32\drivers\etc\hosts from admin mode
	# Start-Process -FilePath "c:\program files\notepad++\notepad++.exe" -ArgumentList "c:\windows\system32\drivers\etc\hosts" -Verb RunAs
	Start-Process -FilePath "c:\program files\notepad++\notepad++.exe" -ArgumentList "c:\windows\system32\drivers\etc\hosts"
}

function Admin-Run-HostEdit {
	# see https://github.com/mgua/hostedit
	
}

function Alias-cdh {
	# cd to home directory
	Set-Location -Path $env:USERPROFILE
} 

function ProfileEdit {
	& notepad.exe $profile
}

Set-Alias -Name he -Value Admin-Edit-Hosts -Description "Edit hosts file in admin mode"
Set-Alias -Name pe -Value ProfileEdit
Set-Alias -Name npp -Value "c:\program files\notepad++\notepad++.exe" -Description "Launch Notepad++ editor"
Set-Alias -Name vi -Value Launch-Nvim -Description "Launh nvim"
Set-Alias -Name np -Value Launch-NotepadPlusPlus
Set-Alias aeh Admin-Edit-Hosts
Set-Alias he Admin-Run-Hostedit
#Set-Alias -Name cdh -Value Alias-cdh -Description "Alias cdh: go to current user home directory"
Set-Alias -Name cdh -Value Alias-cdh 




