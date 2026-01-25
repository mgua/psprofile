# psprofile

A personal tool to manage PowerShell aliases and configurations for Windows command line power users.

Marco Guardigli, october 2023 - january 2026.

mgua@tomware.it

https://github.com/mgua/psprofile

psprofile allows team-level definition and management of PowerShell aliases to automate tasks for Windows users. It provides a unified way to manage your shell environment across different machines and PowerShell versions, bringing Linux-like convenience to Windows PowerShell.

---

## Table of Contents

- [Understanding PowerShell Profiles](#understanding-powershell-profiles)
- [Installation](#installation)
- [Command Reference](#command-reference)
- [Oh My Posh Integration](#oh-my-posh-integration)
- [Git Integration](#git-integration)
- [Chezmoi Integration](#chezmoi-integration)
- [Identity Management](#identity-management)
- [Python Virtual Environment Management](#python-virtual-environment-management)
- [Command Line Tools Integration](#command-line-tools-integration)
- [GNU Tools and Linux-like Commands](#gnu-tools-and-linux-like-commands)
- [Prerequisites](#prerequisites)
- [Troubleshooting](#troubleshooting)
- [Caveats](#caveats)
- [News](#news)
- [Nice to Have List](#nice-to-have-list)

---

## Understanding PowerShell Profiles

### What is a PowerShell Profile?

A PowerShell profile is a script that runs automatically every time you start a PowerShell session. It's the ideal place to:

- Define custom aliases and functions
- Set environment variables
- Configure your prompt appearance (Oh My Posh)
- Load frequently used modules
- Set up your preferred working environment

Think of it as `.bashrc` or `.zshrc` for PowerShell.

### Profile Locations by PowerShell Version

Windows has two main PowerShell versions with **different profile locations**:

#### Windows PowerShell 5.1 (`powershell.exe`)

```
$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

This is the legacy PowerShell that comes pre-installed with Windows.

#### PowerShell Core 7+ (`pwsh.exe`)

```
$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

This is the modern, cross-platform PowerShell. **Recommended for new setups.**

To check which version you're running:

```powershell
$PSVersionTable.PSVersion
```

To see your current profile path:

```powershell
$PROFILE
```

**Note:** The `pinstall` command automatically installs to BOTH locations, so your aliases work regardless of which PowerShell you launch.

### Profile Locations by User Account Type

The actual location of your Documents folder (and thus your profile) varies depending on your Windows configuration:

#### Local User Account

Standard local Windows account:

```
C:\Users\<username>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
C:\Users\<username>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

#### Domain-Based Account (Active Directory)

For domain users in corporate environments, the Documents folder may be redirected to a network share via Group Policy:

```
\\server\users$\<username>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

Or it may use a local cached copy with folder redirection policies. The profile loads from wherever `$PROFILE` points. Check with your IT administrator for the exact configuration.

**Considerations for domain accounts:**
- Profile may load slowly if network share is unavailable
- Some functions may fail if network paths are inaccessible
- Consider keeping a local backup of critical aliases

#### OneDrive-Synced Profile

When OneDrive is configured to sync your Documents folder (common in Microsoft 365 environments), the profile location changes:

```
C:\Users\<username>\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
C:\Users\<username>\OneDrive - <Organization>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

**Important:** The `pinstall` command automatically detects OneDrive redirection using `[Environment]::GetFolderPath('MyDocuments')` and installs to the correct location. It will also warn you if old profiles exist in non-OneDrive locations that PowerShell ignores.

**Benefits of OneDrive sync:**
- Profile automatically syncs across devices
- Backup protection for your customizations
- Easy to restore on new machines

**Potential issues:**
- Sync conflicts if editing on multiple machines simultaneously
- Brief delay on first login while OneDrive syncs

### Profile Scope Types

PowerShell supports multiple profile scopes. psprofile focuses on CurrentUserCurrentHost (the default):

| Scope | Description | Variable |
|-------|-------------|----------|
| All Users, All Hosts | All users, all PS hosts | `$PROFILE.AllUsersAllHosts` |
| All Users, Current Host | All users, current host | `$PROFILE.AllUsersCurrentHost` |
| Current User, All Hosts | Current user, all hosts | `$PROFILE.CurrentUserAllHosts` |
| **Current User, Current Host** | Current user, current host | `$PROFILE` (default) |

---

## Installation

### Quick Start

Open a PowerShell prompt and execute:

```powershell
# Create and enter the psprofile directory
mkdir ~/psprofile
cd ~/psprofile

# Clone the repository (note the dot at the end - clones into current folder)
git clone https://github.com/mgua/psprofile.git .

# Load the profile in current session
. .\profile.ps1

# Install to PowerShell profile locations
pinstall
```

### What `pinstall` Does

The `pinstall` command:

1. Detects your actual Documents folder (handles OneDrive redirection)
2. Creates the profile directories if they don't exist
3. Copies `profile.ps1` to both PS 5.1 and PS 7+ profile locations
4. Optionally creates symbolic links instead of copies (`pinstall -UseSymlink`)
5. Warns about orphaned profiles in wrong locations

### Execution Policy

PowerShell's security policy may block script execution. Fix with:

```powershell
# For current user only (recommended, no admin needed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# For the entire machine (requires admin)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

If you downloaded the file and still get errors:

```powershell
Unblock-File -Path .\profile.ps1
```

### PSReadLine Errors

If you encounter readline errors (common with Oh My Posh):

```powershell
# Run as administrator
Install-Module -Name PSReadLine -Force -SkipPublisherCheck
```

See: https://github.com/JanDeDobbeleer/oh-my-posh/issues/7152

### Reloading the Profile

After making changes, reload without restarting PowerShell:

```powershell
# Reload from installed location
. $PROFILE

# Or reload from psprofile development folder
. .\profile.ps1
```

### Upgrading psprofile

To pull the latest version:

```powershell
cd ~/psprofile
git pull
. .\profile.ps1
pinstall
```

Or use the menu:

```powershell
psmenu  # Select Install Options → Upgrade psprofile
```

**Caution:** `git pull` may overwrite local changes. Commit your customizations first or maintain a fork.

---

## Command Reference

### Profile Management

| Alias | Command | Description |
|-------|---------|-------------|
| `pinstall` | `Profile-Install` | Install profile.ps1 to both PS 5.1 and PS 7+ locations |
| `pinstall -UseSymlink` | | Create symlinks instead of copies (requires admin) |
| `pspe` | `psProfileEdit` | Open the profile in notepad for editing |
| `psmenu` | `Main-Menu` | Show the interactive main menu with install options |

### Alias Listing

| Alias | Command | Description |
|-------|---------|-------------|
| `la` | `Get-Alias` | List all defined PowerShell aliases |
| `ga` | `Get-Alias` | List all defined PowerShell aliases |

### Navigation

| Alias | Command | Description |
|-------|---------|-------------|
| `cdh` | `Alias-cdh` | Change directory to user's home folder (`$env:USERPROFILE`) |
| `ex` | `Launch-Explorer` | Open Windows Explorer (current folder if no path given) |

### File Listing (Linux-style)

| Alias | Command | Description |
|-------|---------|-------------|
| `ll` | `lsll` | Directory listing with hidden files (`dir -Force`) |
| `lla` | `Alias-lla` | Detailed listing with human-readable sizes (like `ls -lah`) |
| `ls` | `Get-LinuxLs` | Linux-style ls emulation with flag support |

The `ls` command supports common Linux flags:

```powershell
ls          # Simple listing
ls -l       # Detailed listing with permissions, size, date
ls -a       # Include hidden files
ls -h       # Human-readable sizes (K, M, G)
ls -lah     # Combined: detailed, hidden, human-readable
```

### Editors

| Alias | Command | Description |
|-------|---------|-------------|
| `vi`, `vim`, `nvim`, `nv` | `Launch-NvimLocal` | Launch Neovim in current shell |
| `nvim-new`, `nv-new` | `Launch-NvimNew` | Launch Neovim in new window/tab |
| `npp`, `np` | `Launch-NotepadPlusPlus` | Launch Notepad++ |
| `mc` | `Launch-MidnightCommander` | Launch Midnight Commander or FAR Manager |

**Neovim launch modes:**

- **Local mode** (`nv`, `vim`, etc.): Runs in current shell, preserves Python venv, environment variables, and works over SSH
- **New window mode** (`nv-new`): Opens in new Windows Terminal tab or PowerShell window, clean environment, won't work over SSH

### File Managers

| Alias | Command | Description |
|-------|---------|-------------|
| `mc` | `Launch-MidnightCommander` | Launch MC in current directory (falls back to FAR) |

The `mc` command intelligently finds the file manager:

1. Checks `C:\Program Files\Midnight Commander\mc.exe`
2. Checks `C:\Program Files (x86)\Midnight Commander\mc.exe`
3. Checks PATH for `mc.exe`
4. Falls back to FAR Manager if MC not found
5. Both launch in current working directory

### System Administration

| Alias | Command | Description |
|-------|---------|-------------|
| `hed` | `Admin-Edit-Hosts` | Edit hosts file with Notepad++ in admin mode |
| `her` | `Admin-Run-HostEdit` | Launch hostedit script in admin mode |
| `cyg` | `Launch-CygwinBash` | Launch Cygwin Bash shell (`c:\cygwin64\bin\bash -l`) |

### Python Virtual Environments

| Alias | Command | Description |
|-------|---------|-------------|
| `lv` | `ListVenvFolders` | List `*venv*` folders in home with sizes |
| `se` | `Select-VirtualEnvironment` | Menu to select and activate any `*venv*` |
| `secd` | `Select-VirtualEnvironmentCd` | Select `venv_*` AND cd to project folder |

### Git

| Alias | Command | Description |
|-------|---------|-------------|
| `gst` | `Get-GitStatus` | Shortcut for `git status` (pass `-s` for short) |

### Identity Management

| Alias | Command | Description |
|-------|---------|-------------|
| `sid` | `Select-Identity` | Switch between Git/SSH identity profiles |

### Oh My Posh

| Alias | Command | Description |
|-------|---------|-------------|
| `oo`, `omp` | `Toggle-OhMyPosh` | Toggle Oh My Posh prompt on/off |

### Chezmoi

| Alias | Command | Description |
|-------|---------|-------------|
| `cmdiff` | `chezdiff` | Edit file in nvim diff mode vs chezmoi source |

---

## Oh My Posh Integration

[Oh My Posh](https://ohmyposh.dev/) is a prompt theme engine that provides beautiful, informative command prompts with support for git status, Python environments, execution time, and more.

### Why Oh My Posh?

- **Visual git status**: See branch, ahead/behind, dirty state at a glance
- **Python venv display**: Shows active virtual environment name
- **Execution time**: See how long commands take
- **Path abbreviation**: Smart path shortening
- **Customizable**: Hundreds of themes and segments

### psprofile Configuration

psprofile uses the `slimfat` theme by default, configured at the top of `profile.ps1`:

```powershell
$script:OmpThemePath = "$env:POSH_THEMES_PATH\slimfat.omp.json"
$script:OmpEnabled = $true
```

### Recommended Themes

These themes properly display Python venv, git branch, and current path:

| Theme | Style |
|-------|-------|
| `slimfat` | Clean, informative (default) |
| `tonybaloney` | Python-focused |
| `space` | Minimal with spacing |
| `smoothie` | Colorful, rounded |
| `rudolfs-dark` / `rudolfs-light` | Dark/light variants |
| `powerlevel10k_modern` | Feature-rich |
| `poshmon` | Pokemon-inspired |
| `slim` | Minimal single-line |

### Installation

```powershell
# Via winget (recommended)
winget install JanDeDobbeleer.OhMyPosh

# Via psmenu
psmenu  # Select "Install Options" → "oh-my-posh"
```

### Theme Repository Setup

psprofile expects the oh-my-posh repository cloned to your home folder for theme access:

```powershell
mkdir ~/oh-my-posh
cd ~/oh-my-posh
git clone https://github.com/JanDeDobbeleer/oh-my-posh.git .
```

This provides access to all themes in `~/oh-my-posh/themes/`.

**Why clone the repo?** The `$env:POSH_THEMES_PATH` variable can be unreliable. Cloning ensures consistent theme access.

### Changing the Theme

Edit the theme path in `profile.ps1`:

```powershell
$script:OmpThemePath = "$env:USERPROFILE\oh-my-posh\themes\powerlevel10k_modern.omp.json"
```

Then reload: `. $PROFILE`

### Toggling Oh My Posh

Sometimes you need to disable Oh My Posh temporarily:

- SSH sessions where it renders poorly
- Slow prompt on network drives
- Debugging prompt issues
- Clean output for copying

```powershell
oo    # Toggle OFF - restores default "PS C:\path>" prompt
oo    # Toggle ON - reactivates Oh My Posh with configured theme
```

The toggle preserves your session and all other functionality.

### NerdFonts Requirement

Oh My Posh themes use special icons that require a NerdFont. Without one, you'll see boxes or question marks.

```powershell
# Install via psmenu
psmenu  # Select "Install Options" → "NerdFonts"

# Or via chocolatey
choco install hack-nerd-font

# Or via PowerShell module
Install-Module -Name NerdFonts
Import-Module -Name NerdFonts
Install-NerdFont -Name Hack
```

After installing, configure Windows Terminal or your terminal emulator to use the NerdFont (e.g., "Hack Nerd Font").

---

## Git Integration

### Quick Status

```powershell
gst      # git status
gst -s   # git status --short
```

### Identity Switching with `sid`

The `Select-Identity` command manages multiple Git and SSH identities for users who work across different accounts (work, personal, client projects, open source).

#### How It Works

1. Scans for matching identity file pairs in home and `.ssh` directories
2. Shows current identity configuration
3. Presents interactive menu of available identities
4. Backs up current configs to `.bak` files
5. Copies selected identity's configs into place

#### File Structure

Create these files for each identity:

```
~/.gitconfig_<identity>           # Git user config
~/.ssh/config_<identity>          # SSH host configurations
~/.ssh/id_rsa_<identity>          # SSH private key (optional)
~/.ssh/id_rsa_<identity>.pub      # SSH public key (optional)
```

#### Example: Work and Personal Identities

**~/.gitconfig_work**
```ini
[user]
    name = Your Name
    email = your.name@company.com
[core]
    sshCommand = ssh -i ~/.ssh/id_rsa_work
```

**~/.gitconfig_personal**
```ini
[user]
    name = YourHandle
    email = you@personal.com
[core]
    sshCommand = ssh -i ~/.ssh/id_rsa_personal
```

**~/.ssh/config_work**
```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_work
    
Host gitlab.company.com
    HostName gitlab.company.com
    User git
    IdentityFile ~/.ssh/id_rsa_work
```

**~/.ssh/config_personal**
```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_personal

Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_personal
```

#### Usage

```powershell
sid

# Output:
# Current Identity Configuration:
#   Git: Your Name <your.name@company.com>
#   SSH config: exists
#   SSH key: id_rsa exists
#
# Available Identities:
#   personal (has SSH key)
#   work (has SSH key)
#
# ================ Select Identity ================
# 0. personal
# 1. work
#
# [Use arrow keys, press Enter to select]
#
# Switching to identity: personal
#   Backed up .gitconfig -> .gitconfig.bak
#   Copied .gitconfig_personal -> .gitconfig
#   Backed up .ssh/config -> .ssh/config.bak
#   Copied .ssh/config_personal -> .ssh/config
#   Backed up .ssh/id_rsa -> .ssh/id_rsa.bak
#   Copied .ssh/id_rsa_personal -> .ssh/id_rsa
#   Copied .ssh/id_rsa_personal.pub -> .ssh/id_rsa.pub
#
# Identity switched successfully!
#   Git identity: YourHandle <you@personal.com>
```

---

## Chezmoi Integration

[Chezmoi](https://www.chezmoi.io/) is a dotfile manager that helps you manage configuration files across multiple machines securely.

### What is Chezmoi?

Chezmoi solves the problem of keeping dotfiles (configuration files like `.gitconfig`, `.bashrc`, PowerShell profiles, etc.) synchronized across multiple computers while handling:

- **Machine-specific differences**: Templates for different hostnames/OS
- **Secrets management**: Encrypted storage for sensitive data
- **Version control**: Git-backed history of all changes
- **Safe application**: Preview changes before applying

### psprofile + Chezmoi

psprofile provides the `cmdiff` alias for comparing local files with their chezmoi-managed versions.

#### `chezdiff` / `cmdiff` Command

Opens Neovim in diff mode showing your local file alongside the chezmoi source:

```powershell
cmdiff ~/.gitconfig           # Compare .gitconfig with chezmoi version
cmdiff ~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1
cmdiff ~/.ssh/config
```

**What you see:**
- Left pane: Your local file (actual file on disk)
- Right pane: Chezmoi source (what chezmoi would apply)
- Highlighted differences between them

**Use cases:**
- Review local changes before committing to chezmoi
- Understand what `chezmoi apply` would overwrite
- Merge manual changes back into your dotfile repository
- Debug why a config isn't what you expected

### Chezmoi Quick Start

```powershell
# Install chezmoi
choco install chezmoi
# or: winget install twpayne.chezmoi

# Initialize with your dotfiles repo
chezmoi init https://github.com/yourusername/dotfiles.git

# See what would be applied
chezmoi diff

# Apply your dotfiles
chezmoi apply

# Add a new file to chezmoi management
chezmoi add ~/.gitconfig
chezmoi add $PROFILE

# Edit a managed file (opens in $EDITOR, updates source)
chezmoi edit ~/.gitconfig

# See the source file location
chezmoi source-path ~/.gitconfig
# Returns: ~/.local/share/chezmoi/dot_gitconfig
```

### Typical Chezmoi Workflow

```powershell
# 1. Make a change to a config file locally
notepad ~/.gitconfig

# 2. Compare with chezmoi source
cmdiff ~/.gitconfig

# 3. If you want to keep the changes, re-add to chezmoi
chezmoi add ~/.gitconfig

# 4. Commit and push
chezmoi cd                    # cd to chezmoi source directory
git add -A
git commit -m "Update gitconfig"
git push

# 5. On another machine, pull and apply
chezmoi update                # git pull + apply
```

### Chezmoi File Naming

Chezmoi uses special prefixes in the source directory:

| Prefix | Meaning | Example |
|--------|---------|---------|
| `dot_` | Translates to `.` | `dot_gitconfig` → `.gitconfig` |
| `private_` | File permissions 0600 | `private_dot_ssh/config` |
| `executable_` | File permissions +x | `executable_script.sh` |
| `symlink_` | Creates symlink | `symlink_dot_vimrc` |
| `.tmpl` suffix | Template file | `dot_gitconfig.tmpl` |

### Managing psprofile with Chezmoi

You can manage your psprofile customizations with chezmoi:

```powershell
# Add your profile to chezmoi
chezmoi add ~/psprofile/profile.ps1

# Or manage the installed profile directly
chezmoi add $PROFILE
```

For machine-specific customizations, use chezmoi templates:

```powershell
# In chezmoi source: dot_gitconfig.tmpl
[user]
    name = Your Name
{{- if eq .chezmoi.hostname "WORK-PC" }}
    email = you@company.com
{{- else }}
    email = you@personal.com
{{- end }}
```

---

## Python Virtual Environment Management

### Listing Environments (`lv`)

Shows all `*venv*` folders in your home directory with their disk usage:

```powershell
lv

# Output:
# venv_webapp: 312.45 MB
# venv_api: 189.23 MB
# test_venv: 156.78 MB
# .venv: 245.00 MB
```

### Selecting and Activating (`se`)

Interactive menu to choose from any `*venv*` folder:

```powershell
se

# Virtual Environments in C:\Users\username
# ================ Select Environment ================
# 0. .venv
# 1. test_venv
# 2. venv_api
# 3. venv_webapp
#
# [Arrow keys to select, Enter to confirm]
#
# Deactivating current environment: C:\Users\username\venv_api
# Activating: venv_webapp
```

**Features:**
- Automatically deactivates current venv if one is active
- Works with any folder matching `*venv*` pattern
- Shows menu using arrow key navigation

### Select with Project Navigation (`secd`)

For projects following the naming convention `venv_projectname` ↔ `projectname`:

```powershell
secd

# Activates the selected venv AND changes to the project folder

# Example: selecting "venv_webapp" will:
# 1. Activate ~/venv_webapp
# 2. cd to ~/webapp
```

**Naming convention:**
```
~/venv_myproject/     # Virtual environment
~/myproject/          # Project source code
```

### Workflow Example

```powershell
# Create a new project with venv
mkdir ~/myproject
cd ~/myproject
python -m venv ~/venv_myproject

# Later, return to work on the project:
secd
# Select "venv_myproject" from menu
# Now you're in ~/myproject with venv activated

# Check your environments anytime
lv
```

---

## Command Line Tools Integration

### Neovim

psprofile provides smart Neovim launching with two modes:

#### Local Mode (Recommended)

```powershell
nv file.txt           # Edit file in current shell
vim *.py              # Edit multiple files
nvim -d file1 file2   # Diff mode
```

**Preserves:**
- Active Python virtual environment
- Current PATH and environment variables
- Works over SSH sessions

#### New Window Mode

```powershell
nv-new file.txt       # Opens in new Windows Terminal tab
nvim-new project/     # Clean environment
```

**Use when:**
- You want a separate window
- Need clean environment without current venv
- **Note:** Won't work over SSH (falls back to local mode with warning)

#### Neovim Path Detection

The launcher searches for nvim.exe in order:
1. `nvim.exe` in PATH (as Application, not alias)
2. `C:\Program Files\Neovim\bin\nvim.exe`
3. `C:\Program Files (x86)\Neovim\bin\nvim.exe`
4. `$env:LOCALAPPDATA\Programs\Neovim\bin\nvim.exe`
5. `$env:USERPROFILE\scoop\shims\nvim.exe`

#### Recommended Neovim Setup

```powershell
# Install neovim
winget install neovim.neovim

# Install a configuration (e.g., kickstart)
cd ~/AppData/Local
git clone https://github.com/nvim-lua/kickstart.nvim.git nvim

# Or use mgua's config
git clone https://github.com/mgua/mg-nvim-2025.git nvim
```

### Midnight Commander / FAR Manager

```powershell
mc              # Launch file manager in current directory
mc /path/to/dir # Launch in specific directory
```

The `mc` command:
1. Tries to find GNU Midnight Commander
2. Falls back to FAR Manager if MC not installed
3. Launches in current working directory
4. Runs in same console (no new window)

```powershell
# Install options
choco install mc      # Midnight Commander
choco install far     # FAR Manager (alternative)
```

### Notepad++

```powershell
np file.txt           # Edit single file
npp *.log             # Edit multiple files
np                    # Open Notepad++ empty
```

### Windows Explorer

```powershell
ex                    # Open Explorer in current directory
ex C:\Projects        # Open specific path
ex .                  # Explicit current directory
```

### Cygwin Integration

Launch a Cygwin bash shell from PowerShell:

```powershell
cyg                   # Launches bash -l from c:\cygwin64\bin\bash
```

**Use cases:**
- Run POSIX commands not available in PowerShell
- Use bash scripts
- Access Cygwin-installed tools
- Familiar environment for Linux users

The shell runs in the same console window (`-NoNewWindow -Wait`), returning to PowerShell when you exit.

---

## GNU Tools and Linux-like Commands

psprofile brings Linux command-line familiarity to Windows PowerShell.

### Built-in Linux-style Commands

#### `ls` - Directory Listing

```powershell
ls              # Simple file listing
ls -l           # Long format (permissions, size, date, name)
ls -a           # Show hidden files (dotfiles)
ls -h           # Human-readable sizes
ls -lah         # Combined: long, all, human-readable
```

**Output comparison:**

```powershell
# ls -lah output:
-rw------  1 DOMAIN\user  DOMAIN\user    5.2K Jan 25 14:30 .gitconfig
drw------  1 DOMAIN\user  DOMAIN\user       0 Jan 25 10:00 .ssh
-rw------  1 DOMAIN\user  DOMAIN\user  156.3M Jan 24 09:15 largefile.zip
```

#### `ll` - Quick Long Listing

```powershell
ll              # Equivalent to dir -Force (shows hidden files)
```

#### `lla` - Detailed Listing with Sizes

```powershell
lla             # Shows: Name, LastWriteTime, Size (human-readable), Mode
```

### Installing GNU Tools

For full Linux tool compatibility, install via Chocolatey:

```powershell
# Essential GNU tools
choco install git           # Includes bash, grep, sed, awk via Git Bash

# Individual tools
choco install grep          # Text search
choco install sed           # Stream editor
choco install awk           # Text processing
choco install less          # Pager (better than more)
choco install curl          # HTTP client
choco install wget          # File downloader
choco install tar           # Archive tool (also built into Windows 10+)

# Modern replacements
choco install fd            # Modern find replacement
choco install ripgrep       # Modern grep replacement (rg)
choco install bat           # Modern cat with syntax highlighting
choco install fzf           # Fuzzy finder
choco install delta         # Better git diff

# Development tools
choco install make          # Build tool
choco install mingw         # GCC compiler suite
```

Or install a bundle via psmenu:

```powershell
psmenu
# Select "Install Options" → "T" for: bat curl fd fzf mingw make
```

### Recommended Tool Configurations

#### fzf (Fuzzy Finder)

```powershell
# Add to profile.ps1 for Ctrl+R history search
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PSReadLineKeyHandler -Chord Ctrl+r -ScriptBlock {
    $result = Get-Content (Get-PSReadLineOption).HistorySavePath | fzf --tac
    if ($result) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($result)
    }
}
```

#### ripgrep (rg)

```powershell
# Search for pattern in current directory
rg "TODO"                   # Find all TODOs
rg -i "error" *.log         # Case-insensitive in log files
rg -l "function"            # List files containing "function"
```

#### bat (Better cat)

```powershell
# Syntax-highlighted file viewing
bat script.py               # With line numbers and highlighting
bat -p script.py            # Plain mode (no decorations)
```

#### fd (Better find)

```powershell
# Find files
fd "\.py$"                  # Find Python files
fd -H .gitconfig            # Include hidden files
fd -t d node_modules        # Find directories only
```

### NerdFonts

NerdFonts are fonts patched with icons used by Oh My Posh, Starship, Powerlevel10k, and other prompt themes.

```powershell
# Install via psprofile menu
psmenu  # Install Options → NerdFonts

# Or via PowerShell module
Install-Module -Name NerdFonts
Import-Module -Name NerdFonts
Install-NerdFont -Name Hack

# Or via Chocolatey
choco install hack-nerd-font
choco install firacode-nerd-font
choco install cascadia-code-nerd-font
```

**Popular NerdFonts:**
- **Hack Nerd Font**: Clean, readable (psprofile default)
- **FiraCode Nerd Font**: Programming ligatures
- **CascadiaCode Nerd Font**: Microsoft's terminal font
- **JetBrainsMono Nerd Font**: Popular for IDEs

After installing, set your terminal font:
1. Windows Terminal: Settings → Profiles → Defaults → Appearance → Font face
2. VS Code: Settings → Terminal › Integrated: Font Family

---

## Prerequisites

### Essential

| Tool | Description | Installation |
|------|-------------|--------------|
| **Git** | Version control | `winget install git.git` |
| **PowerShell 7+** | Modern PowerShell | `winget install Microsoft.Powershell` |

### Recommended

| Tool | Description | Installation |
|------|-------------|--------------|
| **Oh My Posh** | Prompt themes | `winget install JanDeDobbeleer.OhMyPosh` |
| **Neovim** | Modern Vim editor | `winget install neovim.neovim` |
| **Windows Terminal** | Modern terminal | `winget install Microsoft.WindowsTerminal` |
| **NerdFonts** | Icon fonts | `psmenu` → Install → NerdFonts |
| **Notepad++** | Text editor | `winget install notepad++.notepad++` |

### Optional

| Tool | Description | Installation |
|------|-------------|--------------|
| **Chocolatey** | Package manager | `psmenu` → Install → Chocolatey |
| **Midnight Commander** | File manager | `choco install mc` |
| **FAR Manager** | File manager | `choco install far` |
| **Chezmoi** | Dotfile manager | `choco install chezmoi` |
| **VS Code** | IDE | `winget install vscode` |
| **Cygwin** | POSIX tools | [cygwin.com](https://www.cygwin.com/) |
| **fzf** | Fuzzy finder | `choco install fzf` |
| **ripgrep** | Fast grep | `choco install ripgrep` |
| **bat** | Better cat | `choco install bat` |
| **fd** | Better find | `choco install fd` |
| **hostedit** | Hosts manager | [github.com/mgua/hostedit](https://github.com/mgua/hostedit) |

### Quick Install via Menu

```powershell
psmenu
# Select "2: Install Options" for guided installation of all tools
```

---

## Troubleshooting

### Profile Not Loading

1. Check if profile exists: `Test-Path $PROFILE`
2. Check execution policy: `Get-ExecutionPolicy`
3. Manually load to see errors: `. $PROFILE`
4. Check for OneDrive redirection: `[Environment]::GetFolderPath('MyDocuments')`

### Oh My Posh Issues

**Icons showing as boxes:**
- Install a NerdFont and set it in your terminal

**Slow prompt:**
- Toggle off with `oo` command
- Check if on network drive (slower git status)
- Simplify theme

**Python venv not showing:**
- Ensure using a compatible theme (slimfat, tonybaloney, etc.)
- Check `$env:VIRTUAL_ENV` is set

### PSReadLine Errors

```powershell
Install-Module -Name PSReadLine -Force -SkipPublisherCheck
```

### Alias Conflicts

If an alias conflicts with an existing command:

```powershell
# Check what's using the alias
Get-Command ls
Get-Alias ls

# psprofile uses Set-AliasSafe to handle AllScope aliases
```

### SSH/Git Identity Issues

After switching identity with `sid`:
1. Check current identity: `git config user.email`
2. Test SSH: `ssh -T git@github.com`
3. Check SSH agent: `ssh-add -l`

---

## Caveats

- **Work in progress**: psprofile is under active development
- **Customization required**: Review and adapt aliases for your environment
- **Path assumptions**: Some functions assume default installation paths
- **PowerShell version differences**: Some features behave differently between PS 5.1 and PS 7+
- **Admin privileges**: Some operations require elevation (symlinks, hosts editing)
- **OneDrive sync**: May cause brief delays on first login

---

## News

### January 2026
- Identity management (`sid`) for switching Git/SSH profiles with key file support
- Oh My Posh toggle (`oo`/`omp`) for quick enable/disable
- Improved OneDrive detection in `pinstall`
- Chezmoi integration (`cmdiff`) for dotfile diffing
- Midnight Commander fallback to FAR Manager
- Improved Neovim launching (local vs new window modes)
- Comprehensive documentation update

### July 2025
- Cygwin bash integration (`cyg`)
- Updated Midnight Commander path for 64-bit version

### January 2025
- Oh My Posh theme changed to `slimfat` for better venv display
- Improved oh-my-posh initialization

### October 2024
- Improved menu system with cursor navigation (hapylestat)
- `mc` alias for Midnight Commander
- `secd` for combined venv activation and project navigation

### August 2024
- `lla` command for human-readable file sizes
- Linux-style `ls` emulation with `-l`, `-a`, `-h` flags
- Alias visualization in psmenu

### July 2024
- `lv` - list virtual environments with sizes
- `se` - select and activate virtual environment

### May 2024
- `la`/`ga` aliases for listing aliases
- `ex` alias for Windows Explorer

---

## Nice to Have List

- [ ] `svenv`: Select from venv_* folders in home directory
- [ ] `swsl`: Select and launch WSL distribution
- [ ] `srdi`: Select and run Docker image
- [ ] `rl`: Run command and pipe through less pager
- [ ] `pspe`: Edit profile with auto-reload after save
- [ ] Interactive help menu with search
- [ ] Better git menu-driven interface
- [ ] Integration with Claude.ai computer use
- [ ] Docker/container management shortcuts
- [ ] Cloud CLI integrations (aws, az, gcloud)

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Create a Pull Request

## License

This project is provided as-is for personal use. See repository for details.

## Author

Marco Guardigli - mgua@tomware.it

- GitHub: https://github.com/mgua/psprofile
- Related: https://github.com/mgua/hostedit
- Related: https://github.com/mgua/mg-nvim-2025