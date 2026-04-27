#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <thedevilsvoice@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail
#IFS=$'\n\t'

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
CYAN='\033[0;36m'
LCYAN='\033[1;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Some config Variables ----------------------------------------
CATEGORIES=("APPETIZERS" "BREAKFAST" "COOKWARE" "DESSERTS" "DRINKS" "ENTREES" "SAUCES" "SIDES" "SNACKS")
LOGGING_DIR="/tmp/cookbook/log"
MY_DATE=$(date '+%Y-%m-%d-%H')
MY_PWD="${PWD}"
RAW_OUTPUT="${LOGGING_DIR}/generate_cookbook_${MY_DATE}.txt" # log file name
TEX_DIR="/tmp/cookbook"
TEX_OUTPUT="${TEX_DIR}/hacker_cookbook.tex"
TEXMFHOME=$(kpsewhich -var-value=TEXMFHOME)

function directory_setup() {

  # ##### LaTeX #####
  if [ ! -d "${TEX_DIR}" ]; then
    #echo -e "${LRED}Creating LaTeX dir: ${LCYAN}${TEX_DIR}${NC}"
    mkdir -p ${TEX_DIR}
  fi

  # ##### Logging #####
  if [ ! -d "${LOGGING_DIR}" ]; then
    #echo -e "${LRED}Creating log dir: ${LCYAN}${LOGGING_DIR}${NC}"
    mkdir -p ${LOGGING_DIR}
  fi

  # output the results
  echo -e "\n${LCYAN}------------------ Building Cookbook ------------------${NC}" | tee -a "${RAW_OUTPUT}"
  echo -e "${LGREEN}Log file path is: ${LCYAN}${RAW_OUTPUT}${NC}" | tee -a "${RAW_OUTPUT}"
  echo -e "${LGREEN}LaTeX directory is: ${LCYAN}${TEX_DIR}${NC}" | tee -a "${RAW_OUTPUT}"
}

# The frontmatter includes ToC, colophon, etc.
function frontmatter() {
  echo -e "${LGREEN}Adding frontmatter...${NC}" | tee -a "${RAW_OUTPUT}"

  # Copy TeX files to tmp build dir
  cp -Rp .admin/tex/frontmatter ${TEX_DIR}
  cp .admin/tex/preamble.tex ${TEX_DIR}
  cp -Rp .admin/images ${TEX_DIR}

  # build the front pages
  cat .admin/tex/frontmatter/header.tex | tee -a "${TEX_OUTPUT}"
  echo -e "\n" | tee -a "${TEX_OUTPUT}"
  cat .admin/tex/frontmatter/frontmatter.tex | tee -a "${TEX_OUTPUT}"
  echo -e "\n" | tee -a "${TEX_OUTPUT}"
}

# the recipes
function mainmatter() {
  COUNTER=0
  echo -e "${LGREEN}Adding mainmatter...${NC}" | tee -a "${RAW_OUTPUT}"
  cat .admin/tex/mainmatter/mainmatter.tex | tee -a "${TEX_OUTPUT}"

  for i in ${CATEGORIES[@]}; do
    echo -e "${LGREEN}Copying folder: ${LCYAN}${i}${NC}" | tee -a "${RAW_OUTPUT}"
    cp -Rp ${i} ${TEX_DIR}

    # start with the section header
    if [ -f "${TEX_DIR}/${i}/section.tex" ]; then
      echo -e "${LGREEN}Found section header: ${LCYAN}${TEX_DIR}/${i}/section.tex${NC}" | tee -a "${RAW_OUTPUT}"
      NEW_DIR=$(echo "${TEX_DIR}/${i}/images/" | sed 's@/@\\/@g')
      echo -e "${LGREEN}Update image path in section header to: ${LCYAN}${NEW_DIR}${NC}" | tee -a "${RAW_OUTPUT}"
      sed -i -e "s/images\//${NEW_DIR}/g" ${TEX_DIR}/${i}/section.tex
      cat ${TEX_DIR}/${i}/section.tex | tee -a "${TEX_OUTPUT}"
    fi

    THESE_FILES=$(ls ${TEX_DIR}/${i}/*.md)
    for j in $THESE_FILES; do
      sed -i -e "s/images\//${NEW_DIR}/g" ${j} # fix image directory
      sed -i 's|^#|##|' ${j}                   # fix the markdown heading level
      echo -e "${LGREEN}Adding recipe: ${LCYAN}${j}${NC}" | tee -a "${RAW_OUTPUT}"
      echo "\pagebreak" | tee -a "${TEX_OUTPUT}" # new page for every recipe
      echo "\markdownInput{${j}}" | tee -a "${TEX_OUTPUT}"
      ((COUNTER += 1)) # increment recipe count
    done
  done
}

function backmatter() {
  echo -e "${LGREEN}Adding backmatter...${NC}" | tee -a "${RAW_OUTPUT}"
  cat .admin/tex/backmatter/backmatter.tex \
    .admin/tex/backmatter/end.tex | tee -a "${TEX_OUTPUT}"
}

function cleanup() {
  echo "Cleaning up..." | tee -a "${RAW_OUTPUT}"

  # copy final file to original dir
  if [ -f "${TEX_DIR}/hacker_cookbook.pdf" ]; then
    echo -e "${LGREEN}Copying PDF to project dir: ${LCYAN}$${TEX_DIR}/hacker_cookbook.pdf${NC}" | tee -a "${RAW_OUTPUT}"
    cp ${TEX_DIR}/hacker_cookbook.pdf ${MY_PWD}
  else
    echo -e "${LRED}PPDF generation failed.${NC}"
  fi

  # Blow away the temp working dir
  if [ -d "${TEX_DIR}" ]; then
    echo -e "${LGREEN}Erase tmp build dir: ${LCYAN}${TEX_DIR}${NC}" | tee -a "${RAW_OUTPUT}"
    rm -rf ${TEX_DIR}
  fi
}

function main() {

  # Check to see if script is being run from correct relative path
  if [ ! -f ".admin/bin/generate_book.sh" && ! -d ".admin/tex" ]; then
    echo -e "${LRED}Please run this tool from top level of repo clone${NC}"
    exit 1
  fi

  directory_setup

  # remove any stale output file
  if [ -f "${TEX_OUTPUT}" ]; then rm ${TEX_OUTPUT} && touch ${TEX_OUTPUT}; fi

  frontmatter
  mainmatter
  echo -e "${LGREEN}Processed ${COUNTER} recipes total.${NC}" | tee -a "${RAW_OUTPUT}"
  backmatter

  cp ${TEX_OUTPUT} ${MY_PWD}/.admin/tex
  cd ${TEX_DIR} && latexmk -pdf -file-line-error -interaction=nonstopmode -synctex=1 --shell-escape hacker_cookbook

  cleanup
}

main "$@"
