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

# pipenv
if [ -f /usr/bin/pipenv ]; then
	eval "$(/usr/bin/pipenv --completion)"
fi
# invoke and fabric
if [ -f /usr/bin/invoke ]; then
	eval "$(invoke --print-completion-script bash)"
fi
if [ -f /usr/bin/fab ]; then
	eval "$(fab --print-completion-script bash)"
fi


# NVM
if [ -f /usr/share/nvm/init-nvm.sh ]; then
    source /usr/share/nvm/init-nvm.sh
fi

export PAGER=most
export EDITOR=vim
export GOROOT=/usr/lib/go
export GOPATH=$HOME/go
export CARGOPATH=$HOME/.cargo
export GEM_PATH=/home/diogobaeder/.gem/ruby/2.6.0:/usr/lib/ruby/gems/2.6.0:/usr/lib/ruby/gems/2.6.0/gems/
export PATH=/usr/lib/distcc/bin/:$PATH:$GOROOT/bin:$GOPATH/bin:$CARGOPATH/bin
export SKIP_JVM_TESTS=1
export KUBE_EDITOR=~/bin/kube-secret-editor.py
export KUBECONFIG=~/yougov/kubernetes/client/config:~/yougov/kubernetes/client/self
export SOUP_NTLM_AUTH_DEBUG=
export DISTCC_HOSTS="localhost +zeroconf"

export VELOCIRAPTOR_URL=https://deploy.yougov.net/
export VELOCIRAPTOR_AUTH_DOMAIN=deploy.yougov.net

export FBTOKEN=$(keyring get fogbugz diogo.baeder)
export FBUSER=diogo.baeder@yougov.com
export FBURL=https://yougov.manuscript.com/

#export MONGO_HOME=$HOME/Downloads/mongodb-linux-x86_64-3.0.6/bin/
export MONGO_HOME=$HOME/Downloads/mongodb-linux-x86_64-3.4.10/bin/
#export MONGO_HOME=$HOME/Downloads/mongodb-linux-x86_64-3.6.1/bin/
#export MONGO_DIR=/run/diogobaeder/mongo_bix2ui

export INSTACLEAN_CLIENT_ID=a9abacba3a354009892ddd098bdc2a2e
export INSTACLEAN_CLIENT_SECRET=$(keyring get instaclean a9abacba3a354009892ddd098bdc2a2e)

export BIXMODEL_TEST_DB=postgresql+psycopg2://bixmodel:bixmodel@localhost/bixmodel_test

. paver_autocomplete
. _kubectl-completion

kns () {
    if [[ $# -eq 0 ]]
    then
        kubectl config get-contexts
    else
        kubectl config set-context $(kubectl config current-context) --namespace $@
    fi
}
kevents ()
{
    kubectl get events --sort-by=.lastTimestamp -ocustom-columns=LAST_TS:.lastTimestamp,NAME:.metadata.name,MSG:.message $* | grep --color=auto -v 'Search Line limits were exceeded'
}

alias kc='kubectl config get-contexts'
alias ksc='kubectl config use-context'
alias kedit-secret="kubectl edit secret"
