# psprofile

A personal tool to manage powershell aliases, for windows command line power users.

Marco Guardigli, october 2023.

mgua@tomware.it



psprofile allows team level definition and management of powershell aliases to automate tasks,
for windows users.

## Usual Prerequirements:
psprofile is an integration tool. 
It simplifies and streamlines working in windows from powershell command line interface.
the tools usual  are:
- Windows operating system, with powershell interpreter
- ohmyposh prompt 
- nerdfonts
- notepad++
- neovim / vim
- chocolatey package manager
- winget package manager
- microsoft visual studio code
- windows terminal

Read down for more details.


## Caveats
psprofile is a personal too. It is imperfect. It is a work in progress. 

It is flexible, and requires customization for you use.
It is powerful, and as any powerful tools, requires conscious use.


## Installation
Open a powershell prompt and, from your home folder, execute the following commands
```
    mkdir psprofile
    cd psprofile
    git clone https://github.com/mgua/psprofile.git .
    . .\profile.ps1
    pinstall
```

Check the code for the defined aliases, and define yours.
Once done, _pinstall_ alias command will install your profile.ps1 in your windows profile, to have it automatically loaded by powershell 
every time you open a command window.

It can be that PowerShell script execution is not allowed. 
To authorize, execute the following line from a powershell prompt:

```
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

Alternatively, the profile.ps1 script must be signed to be executed. 
see https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_signing?view=powershell-7.4

The pinstall command is an alias, defined within profile.ps1. This alias performs profile installation, 
copying the profile.ps1 script to the file specified by the $PROFILE environment variable, which is something like:

```
C:\Users\{USERNAME}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```


## Command alias defined (incomplete list. see code)
```
  - pinstall      install profile.ps1 after edit
  - la            list all defined aliases (List Alias)
  - ga            list all defined aliases (Get Alias)
  - hed           edit hosts file in admin mode
  - her           launch hostedit in admin mode (to manage local wsl address resolution)
  - vi            launch neovim
  - vim           launch neovim
  - nvim          launch neovim
  - npp           launch notepad++
  - np            launch notepad++
  - cdh           cd to home
  - ll            ls -la
  - pspe          edit powershell profile
  - lv            list virtual environment (venv folders) with related sizes
  - se            select and activate a virtual environment
  - psmenu        show menu
  - secd          select python virtual environment and cd to project folder 
                  assumes venv folder names like .\venv_projectname
                  being .\projectname the corresponding project folder
```



### other tools
We assume that some prerequired tools are installed, being those referenced in the alias commands

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
with this you edit the running profile. 
it is usually better to edit the profile.ps1 downloaded from your fork, 
and then execute pinstall from its folder.



## News


(jul 2024):
- le (list environments: list venv folders in current location, with sizes)
- se (select environment: allows to choose and activate a venv)

(oct 2024):
- a better menu generation. Choice with cursor movement. 
taken from github\hapylestat (see code)
This new menu code is not operational everywhere. It works in _secd_ alias.

(nov 2024):
- Improved documentation.


## Nice to have list:
- Documentation improvement
- Delp menu
- Integration with command line file manager, like mc or far
- Integration with claude.ai computer use features.
- better integration with OhMyPosh
- better integration with git, and with its many options, that could be used via a menu-driven interface
- better integration with local GNU tools, like find, grep, fd, ripgrep, fzf.





