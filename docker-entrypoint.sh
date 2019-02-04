#!/usr/bin/env bash
set -e

# run Jenkins as user jenkins
su jenkins -c 'cd $HOME; /usr/local/bin/jenkins.sh'

# Composer update
composer self-update