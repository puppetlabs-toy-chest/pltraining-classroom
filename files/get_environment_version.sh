#! /bin/sh

if (( $# != 1 )); then
  echo "Call this script with the name of the environment"
  echo "Example: ${0} production"
  exit 1
fi

CODEDIR='/etc/puppetlabs/code/environments'
CODESTAGE='/etc/puppetlabs/code-staging/environments'
GITCODEDIR="${CODEDIR}/${1}/.git"
GITCODESTAGE="${CODESTAGE}/${1}/.git"

# Are we using old-school git clones?
if [ -d ${GITCODEDIR} ]; then
  git --git-dir ${GITCODEDIR} rev-parse --short HEAD
  
elif [ -d ${GITCODESTAGE} ]; then 
  git --git-dir ${GITCODESTAGE} rev-parse --short HEAD

else
  date '+%s'
fi

