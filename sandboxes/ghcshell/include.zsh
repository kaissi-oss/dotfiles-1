#!/usr/bin/env zsh

ghcshell() {
    mkdir -p ~/.cabal
    mkdir -p ~/.ghc

    if [ ! -d /opt/ghc ]; then
        sudo mkdir -p /opt/ghc
        sudo chown -R $USER:`id -g -n` /opt/ghc
    fi

    _docker_zsh "ghcshell" "/project" \
                "-v ~/.cabal:/home/$USER/.cabal" \
                "-v ~/.ghc:/home/$USER/.ghc"
}

ghcshell-clean() {
    rm -r ~/.cabal
    rm -r ~/.ghc
}

ghcshell-idea() {
    if [[ $1 == "" ]]; then
        echo "Container name not passed in" >&2
        return 1
    fi

    ghcshell-mount $1
    ghcshell-env
    nohup idea.sh > /tmp/idea.log &
}

compdef __list_docker_containers ghcshell-idea

ghcshell-env() {
    export PATH=~/.cabal/bin/:$PATH
}

ghcshell-mount() {
    if [[ $1 == "" ]]; then
        echo "Container name not passed in" >&2
        return 1
    fi

    local name=$1
    local port=$(_get_docker_ssh_port $1)

    echo "Mounting /opt/ghc (port: $port)"

    sshfs $USER@0.0.0.0:/opt/ghc /opt/ghc -p $port -o follow_symlinks
}

compdef __list_docker_containers ghcshell-mount