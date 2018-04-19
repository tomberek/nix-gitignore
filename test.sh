#!/usr/bin/env bash

set -euo pipefail

touches() { (
    mkdir -p "$1"; cd "$1"; shift
    touch "$@"
); }

create-tree() { (
    mkdir -p "$1"; cd "$1"

    touches 1-simple         {1,2,3,4,5,^,$,^$,$^,[,[[,],]],]]],ab,bb,\\,\\\\}

    touches 2-negation       {.keep,10,20,30,40,50}

    touches 3-wildcards      {foo,bar,baz}.html
    touches 3-wildcards/html {foo,bar,baz}.html

    touches 4-escapes        {{*,o{,_,__,?,}ther}.html,other.html{,\$,\$\$}}

    touches 9-expected       {unfiltered,filtered-via-aux-{filter,ignore}}
); }

list-sort() {
    find "$1" -printf '%P\n' | sort
}

verbose-find-diff() {
    echo -e "diffing:\n  $1\n  $2\n"
    diff --color <(list-sort "$1") <(list-sort "$2") || echo
}

create-tree test-tree
install -m644 "$(nix eval --raw -f test.nix ignores)" ./test-tree/.gitignore

nix build -f test.nix git
git="$(readlink result)"; rm result
nixi="$(nix eval -f test.nix nixIgnore  --json | jq -r .)"
nixfa="$(nix eval -f test.nix nixFilterAux --json | jq -r .)"

# 2/3 of 9-expected/* paths should be printed

verbose-find-diff "$nixfa" "$nixi"
verbose-find-diff "$git" "$nixi"

rm -r test-tree
