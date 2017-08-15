#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export HISTCONTROL=ignoredups

#export PYTHONPATH=/usr/lib/python3.4/site-packages
export PYTHONHASHSEED=random
export SITE_PACKAGES=`python -c 'import site; print(site.getsitepackages()[0])'`

alias ls='ls --color=auto'
alias yolo='yaourt -Syyua --force --noconfirm'
PS1='[\u@\h \W]\$ '

if [ -f $SITE_PACKAGES/powerline/bindings/bash/powerline.sh ]; then
	. $SITE_PACKAGES/powerline/bindings/bash/powerline.sh
fi


export PATH=$HOME/bin:$PATH
if [ -f /usr/bin/ruby ] && [ -d $(ruby -e 'print Gem.user_dir') ]; then
	export PATH=$(ruby -e 'print Gem.user_dir')/bin:$PATH
fi


# Virtualenvwrapper
export WORKON_HOME=~/Envs
mkdir -p $WORKON_HOME
if [ -f /usr/bin/virtualenvwrapper.sh ]; then
	source /usr/bin/virtualenvwrapper.sh
fi

export GOROOT=/usr/lib/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

export VELOCIRAPTOR_URL=https://deploy.yougov.net/
export VELOCIRAPTOR_AUTH_DOMAIN=deploy.yougov.net

export MONGO_HOME=$HOME/Downloads/mongodb-linux-x86_64-3.0.6/bin/
#export MONGO_DIR=/run/diogobaeder/mongo_bix2ui

. paver_autocomplete
. fabric_autocomplete
. kubectl-completion

mirror-repo() {
    tmpdir=$(mktemp -d ./repo-XXXXXX)
    git clone --mirror kiln://$1 $tmpdir
    git -C $tmpdir push --mirror gitlab://${2:-$1}.git
    rm -Rf $tmpdir
}
