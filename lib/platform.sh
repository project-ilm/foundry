#!/usr/bin/env bash

platform() {

    if grep -qi microsoft /proc/version 2>/dev/null
    then
        echo WSL
        return
    fi

    unameOut="$(uname -s)"

    case "${unameOut}" in

        Linux*)
            echo Linux
            ;;

        Darwin*)
            echo macOS
            ;;

        FreeBSD*)
            echo FreeBSD
            ;;

        *)
            echo Unknown
            ;;

    esac

}
