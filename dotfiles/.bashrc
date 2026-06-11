# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

alias icat='kitten icat'
alias code='flatpak run com.visualstudio.code'

eval "$(starship init bash)"

# Comprueba si es una sesión interactiva en Bash
if [[ $- == *i* ]]; then
  # commands to run in interactive sessions can go here

  # aliases
  alias nv='nvim'
  alias ls='eza --icons=always'
  alias grep='grep --color=auto'
  alias ff='fastfetch'
  alias kys='exit'
fi
# Configurar nvim como el editor de texto por defecto
export VISUAL="nvim"
export EDITOR="$VISUAL"
