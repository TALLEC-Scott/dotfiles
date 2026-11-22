# Dotfiles Repository


This repository contains configuration files for a personalized development environment.
Everything is managed with [Nix](https://nixos.org) and [Home Manager](https://github.com/nix-community/home-manager), so it works on any Linux distro or WSL (no macOS).

## **Included Files**

- `flake.nix`: the profiles
- `home/base/`: bash, vim, git, fastfetch and everyday CLI tools (every profile)
- `home/dev.nix`: compilers and dev tools
- `home/personal/`: secrets, home VPN, NAS and KeePassXC sync
- `.bashrc`, `.bash_aliases`, `.vimrc`: my shell and vim config, still usable without Nix
- `bootstrap.sh`: setup script for a new machine

### **Profiles**

- `scott`: base + dev + personal (my PC)
- `work`: base + dev (company machine, no personal secrets)
- `server`: base + personal
- `minimal`: base only

---

## **Getting Started**

### **1. Clone and install**
```bash
git clone https://github.com/TALLEC-Scott/dotfiles.git ~/home/dotfiles
cd ~/home/dotfiles && ./bootstrap.sh <profile>   # default: scott
exec bash
```
`bootstrap.sh` installs Nix if needed and applies the profile. Existing `~/.bashrc`, `~/.vimrc`, ... are renamed to `*.backup`.

If the username or CPU is different, add an entry in `flake.nix` first:
```nix
work-jdoe = mkHome { modules = profiles.work; username = "jdoe"; };
```

### **2. Secrets (personal profiles only)**
Secrets are encrypted in `secrets/secrets.yaml` with [sops-nix](https://github.com/Mic92/sops-nix). To decrypt them, copy the age key from KeePassXC (entry `sops age key`) to `~/.config/sops/age/keys.txt` and `chmod 600` it, then run `hms`.

Keep an offline copy of `Passwords.kdbx` (USB or phone): the age key is inside it, and the NAS copy needs the VPN, which needs the age key.

### **3. WSL only**
- Install the JetBrainsMono Nerd Font on Windows (the terminal runs on Windows).
- Startup shortcut to keep WSL running from logon: `conhost.exe --headless wsl.exe -d Ubuntu --exec sleep infinity`
- WireGuard tunnels and Freebox certificates: see `windows/wireguard/README.md`

---

## **Usage**

- `hms`: apply the config after editing it (`home-manager switch --flake ~/home/dotfiles`)
- `update`: update all packages (`nix flake update` + `hms` + `uv tool upgrade --all`), then commit `flake.lock`
- Add a package: `home/base/packages.nix` or `home/dev.nix` (search with `nix search nixpkgs <name>`)
- Edit a secret: `sops secrets/secrets.yaml`
- Roll back: `home-manager generations`, then run `activate` from an older one
- Old generations are deleted after 30 days

### **Home network**
- `vpn-nas up | down | status`: WireGuard to the Freebox, rootless (no sudo). Nothing is routed system-wide, only programs using the SOCKS5 proxy `127.0.0.1:41080` go through home.
- `nas mount | umount`: mounts the Freebox NAS at `~/nas`
- `kp-sync`: syncs the KeePassXC database with the NAS on every save. If both copies changed, run `kp-merge`.
- Firefox: `windows/home.pac` sends Netflix and `mafreebox.freebox.fr` through the VPN. Set it in Network Settings → *Automatic proxy configuration URL* (`file:///C:/Users/<you>/home.pac`) and tick *Proxy DNS when using SOCKS v5*.

### **Notes**
- Vim plugins are installed by Nix (no more vim-plug). Add them in `home/base/vim.nix`.
- GPU tools (nvitop, gpustat, btop) use the Windows NVIDIA driver through `/usr/lib/wsl/lib`.
- Machine-local settings go in `~/.bashrc.local` (not tracked).

*Prompt*: oh-my-posh, Atomic theme. *Font*: JetBrainsMono NFM.

## **TODO**

- ~~Add os conditionals depending on if on wsl or linux~~ / ~~use nix for an os agnostic config~~ (done)
- Think about the git config or ways that we could sync configs accross environments
- add ide specific configs and plugins
- add style rules and lint rules that fit my taste
- add tool or skills config for agentic coding
- add outlook and workflow scripts
- add windows powertoys config
- ~~include all util installation in a single script~~ (done: `bootstrap.sh`)
---

## **Credits**

- [Home Manager](https://github.com/nix-community/home-manager)
- Inspiration from various dotfiles repositories.
