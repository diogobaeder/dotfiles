#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export HISTCONTROL=ignoreboth

export PYTHONHASHSEED=random
export SITE_PACKAGES=`python -c 'import site; print(site.getsitepackages()[0])'`
#export PYTHONPATH=$SITE_PACKAGES

alias ls='ls --color=auto'
#PS1='[\u@\h \W]\$ '

if [ -f ~/.bash_prompt.py ]; then
	PROMPT_COMMAND='PS1="$(python ~/.bash_prompt.py)"'
fi


export PATH=$HOME/.config/composer/vendor/bin:$HOME/bin:$PATH
if [ -f /usr/bin/ruby ] && [ -d $(ruby -e 'print Gem.user_dir') ]; then
	export PATH=$(ruby -e 'print Gem.user_dir')/bin:$PATH
fi


# Virtualenvwrapper
export WORKON_HOME=~/Envs
export VIRTUAL_ENV_DISABLE_PROMPT=1
mkdir -p $WORKON_HOME
if [ -f /usr/bin/virtualenvwrapper.sh ]; then
	source /usr/bin/virtualenvwrapper.sh
fi

export EDITOR=vim
export GOROOT=/usr/lib/go
export GOPATH=$HOME/go
export CARGOPATH=$HOME/.cargo
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin:$CARGOPATH/bin
export SKIP_JVM_TESTS=1
export KUBE_EDITOR=~/bin/kube-secret-editor.py
export KUBECONFIG=~/yougov/kubernetes/client/config

export VELOCIRAPTOR_URL=https://deploy.yougov.net/
export VELOCIRAPTOR_AUTH_DOMAIN=deploy.yougov.net

export FBTOKEN=$(keyring get fogbugz diogo.baeder)
export FBUSER=diogo.baeder@yougov.com
export FBURL=https://yougov.manuscript.com/

#export MONGO_HOME=$HOME/Downloads/mongodb-linux-x86_64-3.0.6/bin/
export MONGO_HOME=$HOME/Downloads/mongodb-linux-x86_64-3.4.10/bin/
#export MONGO_HOME=$HOME/Downloads/mongodb-linux-x86_64-3.6.1/bin/
#export MONGO_DIR=/run/diogobaeder/mongo_bix2ui

. paver_autocomplete
. fabric_autocomplete
. kubectl-completion

kns () {
    if [[ $# -eq 0 ]]
    then
        kubectl config get-contexts
    else
        kubectl config set-context $(kubectl config current-context) --namespace $@
    fi
}
alias kc='kubectl config get-contexts'
alias ksc='kubectl config use-context'
alias kedit-secret="kubectl edit secret"
