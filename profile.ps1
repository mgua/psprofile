# this is my powershell alias file
# mgua@tomware.it
#
# save it in C:\Users\<username>\Documents\profile.ps1
#
# see https://stackoverflow.com/questions/24914589/how-to-create-permanent-powershell-aliases
#

function Launch-Nvim {
	
}

function Launch-NotepadPlusPlus {
	
}

function Admin-Edit-Hosts {
	# edit c:\windows\system32\drivers\etc\hosts from admin mode
	
}

function Admin-Run-HostEdit {
	# see https://github.com/mgua/hostedit
	
}

function Alias-cdh {
	# cd to home directory
	Set-Location -Path $env:USERPROFILE
} 

Set-Alias vi Launch-Nvim
Set-Alias npp Launch-NotepadPlusPlus
Set-Alias aeh Admin-Edit-Hosts
Set-Alias he Admin-Run-Hostedit
Set-Alias -Name cdh -Value Alias-cdh -Description "Alias cdh: go to current user home directory"




