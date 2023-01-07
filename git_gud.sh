#!/bin/bash

set -euo pipefail

SEARCH=${1-}

all_branches() {
    git branch | xargs echo | sed 's/* //g' | sed "s/ /\n/g"
}

ask_branch() {
    BRANCH=${1-}
    read -p "$BRANCH [Y/n]? " ASK

    if [[ -z $ASK ]] || [[ $ASK == "y" ]] || [[ $ASK == "Y" ]]; then
        git push origin "$BRANCH"
        exit 0
    fi

    RESULT=$(all_branches | fzf --height 10 --reverse)
    git push origin "$RESULT"
}

if [[ -z $SEARCH ]]; then
    CURRENT_BRANCH=$(git branch | grep '*' | sed 's/* //g')
    ask_branch $CURRENT_BRANCH
    exit 0
fi

for branch in $(all_branches); do
    b_idx=0
    for (( i=0; i<${#SEARCH}; i++ )); do
        for (( ; b_idx<${#branch}; b_idx++ )); do
            if [[ "${SEARCH:$i:1}" == "${branch:$b_idx:1}" ]]; then
                b_idx=$((b_idx + 1))
                continue 2
            fi
        done
        continue 2
    done
    if [[ $i -eq ${#SEARCH} ]]; then
        break 2
    fi
done

ask_branch $branch