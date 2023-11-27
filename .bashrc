#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load other parts
if [ -f ~/.bash_variables ]; then
	source ~/.bash_variables
fi

if [ -f ~/.bash_aliases ]; then
	source ~/.bash_aliases
fi

if [ -f ~/.bash_functions ]; then
	source ~/.bash_functions
fi

if [ -f ~/.bash_completions ]; then
	source ~/.bash_completions
fi

# Starship prompt
if [ -f /usr/bin/starship ]; then
	eval "$(starship init bash)"
fi

# Setup NVM environment
if [ -f /usr/share/nvm/init-nvm.sh ]; then
    source /usr/share/nvm/init-nvm.sh
fi
