# Dotfiles Repository


This repository contains configuration files for a personalized development environment.

## **How it works**

Everything is managed by [Nix](https://nixos.org) + [Home Manager](https://github.com/nix-community/home-manager),
so the same setup works on any Linux distro and WSL, with no `apt`/`dnf`/`pacman` involved. Linux only (no macOS).

| Path | What |
| --- | --- |
| `flake.nix` | Entry point; one `homeConfigurations.<host>` per machine (`scott`, `scott-arm`) |
| `home/packages.nix` | All CLI tools (previously spread across apt, cargo, go, uv, source builds) |
| `home/bash.nix` | Bash options, env vars, completion, oh-my-posh prompt; loads `.bashrc` |
| `home/vim.nix` | Vim + plugins (dracula, airline, coc.nvim, spaceduck, vim-rainbow); loads `.vimrc` |
| `home/files.nix` | Links `.config/fastfetch` (system info splash, 3DS logo) |
| `.bashrc` / `.vimrc` | Your aliases, functions and vim settings: plain files, still usable without Nix |
| `bootstrap.sh` | One-shot setup on a new machine |

---

## **Getting Started**

### New machine (new job, new PC, fresh WSL)
1. **Host entry.** If the username, home or CPU differs, add a host to `hosts` in `flake.nix`:
   `work = { system = "x86_64-linux"; username = "jdoe"; homeDirectory = "/home/jdoe"; };`
2. **Age key** (decrypts `secrets/secrets.yaml`: API keys, VPN, NAS login).
   - Personal machine: copy it from KeePassXC (entry `sops age key`) to `~/.config/sops/age/keys.txt`, `chmod 600`.
   - Company machine: skip it unless policy allows personal secrets there. Everything else still works; secrets just stay encrypted.
   - The database is on the NAS, which needs the VPN, which needs the age key. **Keep an offline copy of `Passwords.kdbx`** (USB or phone).
3. **Install:**
   ```bash
   git clone https://github.com/TALLEC-Scott/dotfiles.git ~/home/dotfiles
   cd ~/home/dotfiles && ./bootstrap.sh <host>   # default host: scott
   exec bash
   ```
   Existing `~/.bashrc`, `~/.vimrc`, ... become `*.backup`.
4. **KeePassXC database** (personal machine): `vpn-nas up && kp-merge` pulls it from the NAS into `~/.local/share/keepassxc/`.
5. **Windows (WSL only):** install the JetBrainsMono Nerd Font on Windows; WireGuard tunnels and Freebox certificates: `windows/wireguard/README.md`.
6. **Always on (WSL):** a Windows Startup shortcut keeps WSL running from logon (its session starts the user services):
   target `C:\Windows\System32\conhost.exe`, arguments `--headless C:\Windows\System32\wsl.exe -d Ubuntu --exec sleep infinity`.
   On a **server** you SSH into, also run `loginctl enable-linger $USER` (sudo on stricter distros) so services keep running after logout.
7. **Check:** `which bat eza rg` → `~/.nix-profile/bin`; `vpn-nas up && nas mount` (personal machine).

### Day to day
- Edit a file in the repo, then apply it: `hms` (alias for `home-manager switch --flake ~/home/dotfiles`)
- Add a tool: add it to `home/packages.nix` (search with `nix search nixpkgs <name>`), then `hms`
- Update everything: `update` (`nix flake update` + switch + `uv tool upgrade --all`)
- Roll back: `home-manager generations`, then run the `activate` script of an older generation
- Machine-local settings go in `~/.bashrc.local` (not tracked)

### Secrets (sops-nix)
API keys are stored encrypted in `secrets/secrets.yaml` and decrypted on `hms` by
[sops-nix](https://github.com/Mic92/sops-nix), then exported as env vars (`home/secrets.nix`).

- Edit / add a key: `sops secrets/secrets.yaml`, add the name to `envSecrets` in `home/secrets.nix`, then `hms`
- The age private key is `~/.config/sops/age/keys.txt`. **Back it up in KeePassXC.** Without it, the secrets cannot be decrypted.
- New machine: copy the age key to that path (`chmod 600`) before running `bootstrap.sh`
- Another machine/person: add its age public key to `.sops.yaml`, then `sops updatekeys secrets/secrets.yaml`

### Home network (VPN + NAS)
- `vpn-nas up | down | status`: WireGuard to the Freebox, rootless (wireproxy as a systemd user service: starts with WSL, restarts if it dies; config in sops; no sudo). Nothing is routed system-wide: only programs using the SOCKS5 proxy `127.0.0.1:41080` go out through home (`nas`, `kp-sync`, and Firefox for Netflix).
- Netflix + Freebox admin (mafreebox.freebox.fr) in Firefox (Windows): copy `windows/home.pac` to `C:\Users\<you>\home.pac`; Firefox → Settings → Network Settings → *Automatic proxy configuration URL* `file:///C:/Users/<you>/home.pac` + tick *Proxy DNS when using SOCKS v5*. Needs `vpn-nas up`. Only `mafreebox.freebox.fr` goes through it.
- `nas mount | umount | status | log`: mount the Freebox NAS (FTP, rclone/FUSE, no sudo) at `~/nas`. Needs `vpn-nas up`.
- KeePassXC database: `~/.local/share/keepassxc/Passwords.kdbx` (in WSL). `kp-sync` (runs on every save and hourly) syncs it with the NAS copy both ways when only one side changed (starts the VPN itself); if both changed it stops and you run `kp-merge` (KeePassXC entry merge, asks the master password). Logs: `journalctl --user -u kp-sync`.
- Windows tunnels (admin only / full): see `windows/wireguard/README.md`.

### Vim plugins
Plugins are installed by Nix, so vim-plug is no longer used. To add one, put it in `home/vim.nix`:
a `pkgs.vimPlugins.<name>` entry, or a `fromGitHub { ... }` entry if it is not in nixpkgs.

### Notes
- **WSL GPU tools**: `/usr/lib/wsl/lib` is added to `LD_LIBRARY_PATH` so nvitop, gpustat and btop see the NVIDIA driver.
  On a native distro with an NVIDIA GPU, use [nixGL](https://github.com/nix-community/nixGL) or the distro's driver libs.
- **Font**: JetBrainsMono Nerd Font is installed by Nix, but on WSL the terminal is a Windows app, so install the font on Windows too.

---

*Prompt*: oh-my-posh, Atomic theme (configured in `home/bash.nix`). *Font*: JetBrainsMono NFM.

## **TODO**

- ~~Add os conditionals depending on if on wsl or linux~~ / ~~use nix for an os agnostic config~~ (done: Home Manager flake)
- Think about the git config or ways that we could sync configs accross environments
- add ide specific configs and plugins
- add style rules and lint rules that fit my taste
- add tool or skills config for agentic coding
- add outlook and workflow scripts
- add windows powertoys config
- ~~include all util installation in a single script~~ (done: `bootstrap.sh` + `home/packages.nix`)
---

## **Credits**

- [Home Manager](https://github.com/nix-community/home-manager)
- Inspiration from various dotfiles repositories.
