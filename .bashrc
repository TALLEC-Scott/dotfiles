# Loaded by Home Manager (home/base/bash.nix), which also sets history, completion,
# the prompt and env vars. Can still be sourced on its own without Nix.

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

# Aliases: with Home Manager they are inlined from .bash_aliases (home/base/bash.nix);
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

# CUDA toolkit
if [ -d /usr/local/cuda ]; then
    export CUDA_PATH=/usr/local/cuda
    export PATH=$PATH:$CUDA_PATH/bin
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}/usr/local/cuda/lib64
    export LIBRARY_PATH=${LIBRARY_PATH:+$LIBRARY_PATH:}/usr/local/cuda/lib64
    export LDFLAGS="-L/usr/local/cuda/lib64"
fi

# KeePassXC database (synced with the NAS by kp-sync)
export KPDB="${KPDB:-${XDG_DATA_HOME:-$HOME/.local/share}/keepassxc/Passwords.kdbx}"
# kp <search> [timeout]       copy password (cleared after timeout, default 10 s)
# kp <search> -a username     copy another field;  kp <search> -t   copy TOTP code
kp() { keepassxc-cli clip -b "$KPDB" "$@"; }
kps() { keepassxc-cli search "$KPDB" "$@"; }

export PATH="$HOME/.local/bin:$PATH:$HOME/go/bin"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

command -v hf >/dev/null && [ -f ~/.bash_completions/hf.sh ] && . ~/.bash_completions/hf.sh

# fzf key bindings + completion (after `set -o vi` and PATH edits)
command -v fzf >/dev/null && eval "$(fzf --bash)"

# WSL: start in the Linux home when the shell opens in the Windows profile folder
[[ $PWD == /mnt/c/Users/* && $(dirname "$PWD") == /mnt/c/Users ]] && cd ~

clear && fastfetch

# Machine-local settings (not tracked)
[ -f ~/.bashrc.local ] && . ~/.bashrc.local
true
