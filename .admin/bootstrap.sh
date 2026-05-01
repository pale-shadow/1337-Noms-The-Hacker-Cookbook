#!/usr/bin/env bash                                                                                      
#                                                                                                        
# SPDX-FileCopyrightText: ©2023-2026 franklin <smoooth.y62wj@passmail.net>                                    
#                                                                                                        
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v0.1 02/25/2022 Maintainer script
# v0.2 09/24/2022 Update this script
# v0.3 10/19/2022 Add tool functions
# v0.4 11/10/2022 Add automake check
# v0.5 11/16/2022 Handle Docker container builds
# v0.6 07/13/2023 Add required_files and OpenBSD support
# v0.7 04/22/2024 More OpenBSD support

set -euo pipefail
IFS=$'\n\t'

RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
LBLUE='\033[1;34m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MY_OS="unknown"
OS_RELEASE=""
CONTAINER=false
DOCUMENTATION=false

DEB_PKG=(fig2dev gnuplot)

function run_aclocal() {
  if [ "${MY_OS}" != "openbsd" ]; then
    echo -e "${LBLUE}Checking aclocal version...${NC}"
    acl_ver=$(aclocal --version | awk '{print $NF; exit}')
    echo "    $acl_ver"

    echo -e "${CYAN}Running aclocal...${NC}"
    #aclocal -I m4 $ACLOCAL_FLAGS || exit 1
    aclocal -I config || exit 1
  else
    AUTOCONF_VERSION=2.71 AUTOMAKE_VERSION=1.16 aclocal -I config || exit 1
  fi
  echo -e "${CYAN}.. done with aclocal.${NC}"
}

function run_autoheader() {
  echo "Checking autoheader version..."
  ah_ver=$(autoheader --version | awk '{print $NF; exit}')
  echo "    $ah_ver"

  echo "Running autoheader..."
  autoheader || exit 1
  echo "... done with autoheader."
}

function run_automake() {
  if [ "${MY_OS}" != "openbsd" ]; then
    echo "Checking automake version..."
    am_ver=$(automake --version | awk '{print $NF; exit}')
    echo "    $am_ver"

    echo "Running automake..."
    automake -a -c --add-missing || exit 1
    #automake --force --copy --add-missing || exit 1
  else
    AUTOCONF_VERSION=2.71 AUTOMAKE_VERSION=1.16 automake -a -c --add-missing || exit 1
  fi
  echo "... done with automake."
}

function run_autoconf() {
  if [ "${MY_OS}" != "openbsd" ]; then
    echo -e "${LGREEN}Checking autoconf version...${NC}"
    ac_ver=$(autoconf --version | awk '{print $NF; exit}')
    echo -e "${LGREEN}Autoconf version: $ac_ver${NC}"
    echo "Running autoconf..."
    autoreconf -i || exit 1
  else
    # this is for OpenBSD systems
    ac_ver="2.71"
    echo "Running autoconf..."
    AUTOCONF_VERSION=2.71 AUTOMAKE_VERSION=1.16 autoreconf -i || exit 1
  fi
  echo "... done with autoconf."
}

function check_installed() {
  if ! command -v ${1} &>/dev/null; then
    echo "${1} could not be found"
    exit
  fi
}

function required_files() {
  declare -a required_files=("AUTHORS" "ChangeLog" "NEWS")

  for xx in ${required_files[@]}; do
    if [ ! -f "${xx}" ]; then
      echo -e "${LGREEN}Creating required file ${xx} since it is not found.${NC}"
      #touch "${xx}"
      ln -s README.md ${xx}
    else
      echo -e "${LBLUE}Found required file ${xx}.${NC}"
    fi
  done

  if [ ! -d "config/m4" ]; then mkdir -p config/m4; fi
}

function main() {
  required_files

  if [ ! -d "config/m4" ]; then mkdir -p config/m4; fi
  if [ ! -d "aclocal" ]; then mkdir aclocal; fi

  run_aclocal
  run_autoconf
  run_automake
  
  # ./configure
  #./config.status

}

main "$@"
