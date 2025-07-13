# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

#Switch caps lock and escape key
# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
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


# some more ls aliases

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
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
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias update='sudo apt -y update && sudo apt -y full-upgrade && sudo apt -y autoremove'
alias pipupdate='pip-review --local --auto && pip cache purge'


alias ninjac='ninja -C compile'
alias glog='git log --all --decorate --oneline --graph'
alias sshtallec='ssh scott@88.160.34.221 -p 50000'
alias netup='sudo service network-manager restart && sudo airmon-ng stop wlp0s20f3mon'
alias gcl='git clone'

alias ghtmp='ghtemplate'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#enables vi style binds in bash
set -o vi

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export PGDATA="$HOME/postgres_data"
export PGHOST="/tmp"
export SERVER_URL="http://127.0.0.1:8080"
export PATH=$PATH:/home/scott/go/bin

# force pip to use venv
export PIP_REQUIRE_VIRTUALENV=true

# used by my git message emote hook project (uncomment and adapt based on your env)
# export LLM_API_URL="http://localhost:11434"
# export LLM_MODEL="gemma3n:e4b"

#API_KEYS
# TODO: Move API keys into a secured file (e.g. .env) with strict permissions for shared machines and possibly encrypted
export OPENAI_API_KEY=
export ANTHROPIC_API_KEY=


# Ricing out env with oh my posh, ( can be used in diff envs like bash and ps)

eval "$(oh-my-posh init bash --config 'https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/atomic.omp.json')"
