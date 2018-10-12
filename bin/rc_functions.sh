#!/usr/bin/env bash

rc_help() {
    echo $1
    echo
    echo "This script requires a .deployrc configuration file. This"
    echo "file should be placed in the directory which the script is"
    echo "run. This is typically the root of your project beside your"
    echo ".travis.yml or Jenkinsfile."
    echo "You may also specify environment-specific parameters in"
    echo "their own .deployrc.env_name files. For example you can"
    echo "create a .deployrc.prod and its values will override the"
    echo "main one when deploying to a environment named prod."
    echo
    echo "The following parameters must be contained either in the"
    echo ".deployrc file or the environment-specific rc file:"
    echo
    echo "distribution=distribution-id"
    echo "local=\"path/to/site\""
    echo "remote=\"s3://mysite.com\""
}

load_rc () {
    # Display rc file info and exit if neither a .depllyrc or rc file for the selected environment is found.
    [ ! -f $PWD/.deployrc ] && [ ! -f $PWD/.deployrc.${environment} ] && rc_help "unable to find rc files" && exit 2

    # Run the .deployrc and then overwrite it with the environment-specific one (if exists)
    [ -f $PWD/.deployrc ] && source ${PWD}/.deployrc
    [ -f $PWD/.deployrc.${environment} ] && source ${PWD}/.deployrc.${environment}

    # exit if we're missing a required setting.
    [ -z "$distribution" ] && rc_help "missing distribution in .deployrc" && exit 2
    [ -z "$local" ] && rc_help "missing local in .deployrc" && exit 2
    [ -z "$remote" ] && rc_help "missing remote in .deployrc" && exit 2
}
