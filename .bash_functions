#!/bin/bash

kns () {
    if [[ $# -eq 0 ]]
    then
        kubectl config get-contexts
    else
        kubectl config set-context $(kubectl config current-context) --namespace $@
    fi
}
