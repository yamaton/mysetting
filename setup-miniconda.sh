#!/usr/bin/env bash

BASEDIR="$(dirname "$(readlink -f "$0")")"
readonly BASEDIR
readonly CONFDIR="${HOME}/confs"

cd "$CONFDIR" || exit
if [[ "$(uname -s)" == "Darwin" ]]; then
    readonly OS="MacOSX"
else
    readonly OS="Linux"
fi

if [[ "$(uname -m)" == "x86_64" ]]; then
    [[ -f ~/.condarc ]] && mv -f ~/.condarc ~/.condarc.backup
    ln -sf "${BASEDIR}/.condarc" ~

    readonly URI="https://repo.anaconda.com/miniconda/Miniconda3-latest-${OS}-x86_64.sh"
    wget -N "$URI"
    bash ./Miniconda3-latest-${OS}-x86_64.sh -b -p "$HOME"/miniconda3

    # shellcheck source=/dev/null
    source ~/miniconda3/etc/profile.d/conda.sh
    conda install -c conda-forge mamba
    mamba update --all
    mamba install pipx
    if [[ -x "$(command -v nvidia-smi)" ]]; then
        mamba create -n tf tensorflow-gpu opencv
    else
        mamba create -n tf tensorflow opencv
    fi
    mamba activate tf
    mamba config --add channels conda-forge --env
else
    echo "Miniconda does not seem to support $(uname -m). Exiting."
fi
