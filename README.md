# Dotfiles Repository


This repository contains configuration files for a personalized development environment.

## **How it works**

Everything is managed by [Nix](https://nixos.org) + [Home Manager](https://github.com/nix-community/home-manager),
so the same setup works on any Linux distro, WSL (and macOS with a new host entry), with no `apt`/`dnf`/`pacman` involved.

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

```bash
git clone https://github.com/TALLEC-Scott/dotfiles.git ~/home/dotfiles
cd ~/home/dotfiles
./bootstrap.sh          # installs Nix if needed, enables flakes, runs home-manager switch
exec bash
```
Existing `~/.bashrc`, `~/.vimrc`, ... are moved to `*.backup` on the first switch.

### Day to day
- Edit a file in the repo, then apply it: `hms` (alias for `home-manager switch --flake ~/home/dotfiles`)
- Add a tool: add it to `home/packages.nix` (search with `nix search nixpkgs <name>`), then `hms`
- Update everything: `update` (`nix flake update` + switch + `uv tool upgrade --all`)
- Roll back: `home-manager generations`, then run the `activate` script of an older generation
- Machine-local settings / secrets go in `~/.bashrc.local` (not tracked)

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
- add an `aarch64-darwin` host for macOS
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
