# Portable interactive bash config.
# Loaded by Home Manager (home/bash.nix -> programs.bash.initExtra), which also
# handles history, shell options, completion, the prompt and env vars.
# Can still be sourced on its own on a machine without Nix.

mkcdir()
{
    mkdir -- "$1" && cd -- "$1"
}
gt()
{
    git tag -a "$1" -m "git tag for $1"
}

function ghtemplate() {
    repo_name=$1
    template_repo=${2:-template-1}
    template_owner=${3:-TALLEC-Scott}

    if [[ -z "$repo_name" ]]; then
        echo "Usage: ghtemplate <repository-name> [template_repo] [template_owner]"
    else
        gh repo create "$repo_name" --private --clone --template="$template_owner/$template_repo"
        cd "$repo_name" || return
    fi
}

# Aliases: with Home Manager they are inlined from .bash_aliases (home/bash.nix);
# without Nix, source them from the repo.
DOTFILES="${DOTFILES:-$HOME/home/dotfiles}"
command -v hms >/dev/null 2>&1 || alias hms >/dev/null 2>&1 || { [ -f "$DOTFILES/.bash_aliases" ] && . "$DOTFILES/.bash_aliases"; }

#enables vi style binds in bash
set -o vi

export PGDATA="$HOME/postgres_data"
export PGHOST="/tmp"
export SERVER_URL="http://127.0.0.1:8080"

# used by my git message emote hook project
export LLM_API_URL="http://localhost:11434"
export LLM_MODEL="gemma3n:e4b"

# CUDA toolkit (only if installed on this machine)
if [ -d /usr/local/cuda ]; then
    export CUDA_PATH=/usr/local/cuda
    export PATH=$PATH:$CUDA_PATH/bin
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}/usr/local/cuda/lib64
    export LIBRARY_PATH=${LIBRARY_PATH:+$LIBRARY_PATH:}/usr/local/cuda/lib64
    export LDFLAGS="-L/usr/local/cuda/lib64"
fi

# API keys: exported from sops-nix secrets (home/secrets.nix)

# KeePassXC database (on WSL, ~/Passwords.kdbx links to the Windows copy)
export KPDB="${KPDB:-$HOME/Passwords.kdbx}"
# kp <search> [timeout]       copy password (cleared after timeout, default 10 s)
# kp <search> -a username     copy another field;  kp <search> -t   copy TOTP code
kp() { keepassxc-cli clip -b "$KPDB" "$@"; }
kps() { keepassxc-cli search "$KPDB" "$@"; }   # list matching entries
# back up the KeePassXC database to the NAS (needs: vpn-nas up && nas mount)
kpbackup() {
    local dst="$HOME/nas/NAS Freebox/0 Documents importants/KeePassXC"
    mountpoint -q "$HOME/nas" || { echo "NAS not mounted: vpn-nas up && nas mount" >&2; return 1; }
    mkdir -p "$dst" &&
    cp "$KPDB" "$dst/Passwords.kdbx" &&
    cp "$KPDB" "$dst/Passwords-$(date +%F).kdbx" &&
    cmp -s "$KPDB" "$dst/Passwords.kdbx" && echo "backed up to $dst"
}

# User PATH entries
export PATH="$HOME/.local/bin:$PATH:$HOME/go/bin"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# hf CLI completion
command -v hf >/dev/null && [ -f ~/.bash_completions/hf.sh ] && . ~/.bash_completions/hf.sh

# fzf key bindings + completion (after `set -o vi` and PATH edits)
command -v fzf >/dev/null && eval "$(fzf --bash)"

# Prompt: oh-my-posh (atomic) is set up by home/bash.nix

# WSL: start in the Linux home when the shell opens in the Windows profile folder
[[ $PWD == /mnt/c/Users/* && $(dirname "$PWD") == /mnt/c/Users ]] && cd ~

# Startup banner (config: ~/.config/fastfetch/config.jsonc)
clear && fastfetch

# Machine-local settings (not tracked)
[ -f ~/.bashrc.local ] && . ~/.bashrc.local
true
