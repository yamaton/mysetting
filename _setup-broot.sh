#!/usr/bin/env bash

readonly NAME=broot
readonly CMD=br
VERSION="$(curl --silent https://formulae.brew.sh/api/formula/${NAME}.json | jq '.versions.stable' | tr -d \")"
readonly VERSION
readonly ZIPFILE="broot_$VERSION.zip"

if [[ -x "$(command -v ${NAME})" ]]; then
    CURRENT="$("$NAME" --version | cut -d ' ' -f2)"
    readonly CURRENT
    if [[ "$VERSION" == "$CURRENT" ]]; then
        echo "... already the latest: ${CMD} ${CURRENT}"
    else
        echo "${CMD} ${VERSION} is available: (current ${CMD} ${CURRENT})"
        read -rp "Upgrade to ${CMD} ${VERSION}? (y/N): " confirm
    fi
fi

if [[ "$1" == "-f" ]] || [[ ! -x "$(command -v ${NAME})" ]] || [[ "$confirm" == [yY] ]]; then
    if [[ "$(uname -s)" == "Darwin" ]]; then
        brew install "$NAME"
    elif [[ "$(uname -s)" == "Linux" ]] && [[ "$(uname -m)" == "x86_64" ]]; then
        readonly URI="https://github.com/Canop/$NAME/releases/download/v$VERSION/$ZIPFILE"
        mkdir -p ~/bin && cd ~/bin
        wget -N "$URI"
        rm -rf build
        unzip "$ZIPFILE"
        rm -f "$ZIPFILE"
        mv "./build/x86_64-linux/$NAME" .
        chmod +x ./"$NAME"
        rm -rf build
    fi
    ./"$NAME" --install
fi
