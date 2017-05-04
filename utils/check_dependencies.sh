#!/usr/bin/env bash

TMP_PATH=${HOME}/tmp
mkdir -p ${TMP_PATH} # Create it if does not exist

ORIGINAL_PATH=`pwd` # Save current directory
source ${UTILS_PATH}/log_messages.sh

# Install/Upgrade pip
if [[ ! $(echo "command -v pip") > /dev/null ]] || [[ ! $(pip --version) =~ $(echo "^pip (9|1[0-9])\.[0-9]+\.[1-9]") ]]; then
  log "Install/upgrade \"pip\""
  cd ${TMP_PATH}
  curl -OL https://bootstrap.pypa.io/get-pip.py
  python2.7 get-pip.py
  rm -rf get-pip.py
  cd ${ORIGINAL_PATH}
fi

# Check for JQ https://stedolan.github.io/jq/
if [[ $(command -v ${BIN_PATH}/jq) > /dev/null ]]; then
  log "Install \"jq\""
  JQ=jq-1.5 # See https://github.com/stedolan/jq/releases/ for new releases
  if [ -d ${TMP_PATH}/${JQ} ]; then
    log "Using cached"
    cd ${TMP_PATH}/${JQ}
  else
    cd ${TMP_PATH}/
    curl -OL https://github.com/stedolan/jq/releases/download/${JQ}/${JQ}.tar.gz
    tar xfz ${JQ}.tar.gz
    rm -rf ${JQ}.tar.gz
    cd ${JQ}
  fi
  ./configure --disable-maintainer-mode --prefix=$(dirname ${BIN_PATH}) > /dev/null
  make > /dev/null
  make install > /dev/null
  [ $? -eq 0 ] && exit 0 || exit 1

  cd ${ORIGINAL_PATH}
fi

# Check for VirtualEnv https://github.com/pypa/virtualenv
# Note: didn't use with ${BIN_PATH} cause there is not a way to perform a custom installation to set it, and
# local and server points to the right bin path by default
if [[ $(command -v virtualenv) > /dev/null ]]; then
  log "Install \"virtualenv\""
  VENV_VERSION=15.1.0 # See https://github.com/pypa/virtualenv/releases for new releases
  VENV_PATH=virtualenv-${VENV_VERSION}
  if [ -d ${TMP_PATH}/${VENV_VERSION} ]; then
    log "Using cached"
    cd ${TMP_PATH}/${VENV_PATH}
  else
    cd ${TMP_PATH}/
    curl -OL https://github.com/pypa/virtualenv/archive/${VENV_VERSION}.tar.gz
    tar xfz ${VENV_VERSION}.tar.gz
    cd ${VENV_PATH}
  fi
  python2.7 setup.py install > /dev/null
  [ $? -eq 0 ] && exit 0 || exit 1

  cd ${ORIGINAL_PATH}
fi
