#!/usr/bin/env bash
set -e
source `dirname "$0"`/rc_functions.sh

# Define help function
function help () {
    echo "deploy.sh - Deploy updated site to s3 and invalidate cloudfront cache."
    echo
    echo "Usage:"
    echo "deploy.sh [-h] [-e env-name]"
    echo
    echo "Options:"
    echo "-h: Displays this information."
    echo "-e: Deployment environment. If not set the branch will determine this."
    rc_help
    exit 1;
}
# Parse arguments into variables.
while getopts ":he:" opt; do
    case $opt in
    e) environment=$OPTARG ;;
    \?) echo "Invalid option: -$OPTARG" >&2 && help ;;
    esac
done

# Exit if this was triggered by a pull request.
if [ "$TRAVIS_PULL_REQUEST" == "true" ] || [ -z "CHANGE_ID" ]; then
    echo "Skipping deploy because it's a pull request"
    exit 0
fi

if [ -z "${environment}" ]; then
    # If using Jenkins
    [ ! -z "$BRANCH_NAME" ] && branch=$BRANCH_NAME
    # If using Travis
    [ ! -z "$TRAVIS_BRANCH" ] && branch=$TRAVIS_BRANCH
    # Deploy to staging if this is on the master branch.
    [ ${branch} == "master" ] && environment=staging
    [ ${branch} == "integration" ] && environment=integration
fi
[ -z "environment" ] && echo "Could not determine deployment environment." && exit 1

# Load all the settings from the rc files.
load_rc

# Install the AWS CLI if it is not present.
if ! [ -x "$(command -v aws)" ]; then
    pip install --user awscli
    export PATH=$PATH:$HOME/.local/bin
fi

aws s3 sync ${local} ${remote} --exclude ".git/*"
aws cloudfront create-invalidation --distribution-id ${distribution} --paths "/*"
