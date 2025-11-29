# Util

## CLI util (Debian-based Linux)


### sh
- ollama (running llms locally)
- [uv](https://docs.astral.sh/uv/getting-started/installation/)
- oh-my-posh

### PyPI
- [ruff](https://docs.astral.sh/ruff/installation/)
- huggingface_hub[cli]
- precommit
- wpm
- nvitop
- nvisel (part of nvitop)
- gpustat
- hyfetch (fallback)
- poetry
- yt-dlp
- docling
- llm
- [bpytop](https://github.com/aristocratos/bpytop) (python version of btop without gpu support, only to be used as a backup)
- visidata
> [!IMPORTANT]  
> To install Python CLI applications, use `uv tool install`


### Deb
- neofetch
- lscpu
- htop
- lazy git
- [lazy docker](https://github.com/jesseduffield/lazydocker)
- [bat](https://github.com/sharkdp/bat) (better cat)
- [glab](https://docs.gitlab.com/editor_extensions/gitlab_cli/)
- tmux
- dust (replacement for du)
- gh
- btm (better htop)
- glances (similar to htop)
- bash-completion (autocomplete)
- ncdu — NCurses Disk Usage: Interactive disk usage analyzer
  ```
  sudo apt install ncdu
  ncdu /  # scan root directory
  ```
  ncdu provides a curses-based interactive interface to browse disk usage, delete files, and visualize disk space consumption. It's great for quickly identifying large files and directories.
  [GitHost](https://code.blicky.net/yorhel/ncdu)] | [Man page](https://manpages.debian.org/bullseye/ncdu/ncdu.1.en.html)

### Cargo
- [spotify-player-cli](https://github.com/aome510/spotify-player)
- [asciinema](https://github.com/asciinema/asciinema)
- [eza](https://eza.rocks/) (a modern replacement for ls) (also avaliable in Debian)
- ripgrep (rg is like grep, but faster and more intuitive (also in Debian)
### From source
- [btop++](https://github.com/aristocratos/btop) (with gpu enabled)


## windows

- powertoys | set shortcuts like CAPSLOCK to control and ALT+Q to ALT+F4, and alt+space to opening up search
  - clipboard shortcut (AI correct a text)
  - PowerToys Run - Spotlight search bar like in MacOS and Linux
  - Awake
  - Hosts File Editor
  - Env Vars
  - WorkSpaces
- f.lux
- cyberDuck - FTP
- OVPN

### PowerShell
- posh-git
- oh-my-posh


### Personal

- Wallpaper Engine 
- NordVPN
- qBitTorrent
- VLC

`TODO` Add windows backup

## Firefox extensions
- u-block origin
- vimium
- Leech Blocker NG
- unpaywall
- return youtube dislike
- sponsorblock
- keypass - offline password manager
- Obsidian clips

## Productivity tools
- Note Taking - Obsidian (synced with git), Confluence (legacy) and Notepad
- Editor - Vim or VsCode (want to try Cursor, neovim and zed)
- Tasks - Gitlab issues, Todoist and Obsidian Kanban Plugin, might want to try taskwarrior or org-mode
## Private Server
- NAS
- P2P torrent client
- limited VM capabilities, limited to 1-2 cpu cores per vm and 1GB of total RAM (should probably migrate), hosts:
  - plex server (transcoding need for streaming is not supported by arm64)
  - websites (scuba diving and portfolio website (WIP))
 
