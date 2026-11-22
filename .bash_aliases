# Aliases: sourced by .bashrc (from the dotfiles repo)

alias grep='grep --color=auto'
alias reload='unset POSH_THEME POSH_SESSION_ID; exec bash'  # unset: hms clears the oh-my-posh cache
alias cat='bat --paging=never'
alias cap="cat -p"
alias ls='eza --icons --git --group-directories-first'
alias ll='ls -al --classify=auto'
alias la='ls -la'
alias l='ls --classify=auto'
alias gww="gcc -Wall -Wextra -std=c99 -pedantic -Werror"
alias gpp="g++ -Wall -Wextra -Werror -pedantic -std=c++20"
alias epiclang="find . -iname '*.h' -o -iname '*.c' -o -iname '*.cc' -o -iname '*.hh' -o -iname '*.hxx' | xargs clang-format -i"
alias gpf="git push --follow-tags"
alias gp="git push"
alias gc="git commit -m"
alias ga="git add"
alias gits="git status"
alias cmb="cmake -S . -B build/"
alias cmr="cmake --build build/"
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias glog='git log --all --decorate --oneline --graph'
alias sshtallec='ssh scott@88.160.34.221 -p 50000'
alias gcl='git clone'
alias ghtmp='ghtemplate'
alias nvitop='nvitop --colorful'

# Nix / Home Manager
alias hms='home-manager switch --flake "$DOTFILES"'
alias update-nix='nix flake update --flake "$DOTFILES" && hms'
alias update-uv='uv tool upgrade --all'
alias update='update-nix && update-uv'
command -v apt >/dev/null && alias update-apt='sudo apt -y update && sudo apt -y full-upgrade && sudo apt -y autoremove'
