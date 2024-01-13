# psprofile

a tool to manage powershell aliases
Marco Guardigli, october 2023

Allows team definition and management of powershell aliases to automate tasks,
for windows users.

## Installation
Open a powershell prompt and, from your home folder, execute the following commands
```
    mkdir psprofile
    cd psprofile
    git clone https://github.com/mgua/psprofile.git .
    . .\profile.ps1
    pinstall
```

Check the code for the defined aliases, and define yours
once done, pinstall command will give you the command to put your profile.ps1 
in your Documents folder and then it will be automatically loaded by powershell 
once you open a prompt

It can also be that PowerShell blocks running local scripts. 
To solve that, set PowerShell to only require remote scripts to be signed using 

```
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```
Alternatively, the local script must be signed to be executed. 
see https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_signing?view=powershell-7.4

### other tools
We assume that some other prerequired tools are installed, being those referenced in the alias commands

```
    git client:     https://git-scm.com/
    neovim:         https://neovim.io/
                    https://github.com/mgua/kickstart.nvim  (multiplatform integrated setup)
    notepad++:      https://notepad-plus-plus.org/
    hostedit:       https://github.com/mgua/hostedit
    oh-my-posh:     https://ohmyposh.dev/

```



## Edit
To edit the powershell profile, from windows, you can run the following command:
```
    notepad $PROFILE
```

