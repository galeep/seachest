#!/bin/bash

# I also live here: 
# https://gist.github.com/galeep/4e00cb262d73674e787444bd63714080#file-install_hashicorp_app-sh

# Written by: https://github.com/elocnatsirt
# This will download any valid Hashicorp product you specify if it exists.
# This script has been tested on Mac OS X and Ubuntu 14.04.5 LTS

NORM=`tput sgr0`
BOLD=`tput bold`

function show_help {
    echo "${BOLD}Hashicorp Application Install Script${NORM}"
    echo ""
    echo "Basic usage: ./$(basename $0) -n terraform"
    echo "Extra fancy: ./$(basename $0) -n packer -a linux_amd64 -v 1.1.1 -b profile"
    echo ""
    echo "${BOLD}Options${NORM}:"
    echo " ${BOLD}-n${NORM}: Name (Required) - Hashicorp application to install."
    echo " ${BOLD}-v${NORM}: Version (Optional) - App version to install. Defaults to 'latest'."
    echo " ${BOLD}-d${NORM}: Directory (Optional) - App installation directory. Defaults to '/opt/\$app'"
    echo " ${BOLD}-b${NORM}: Bash Profile Name (Optional) - Write \$PATH to a profile located at $HOME/.'profile_name'"
    echo " ${BOLD}-a${NORM}: Architecture (Optional) - Executable type for your OS and architecture. Defaults to 'darwin_amd64'."
    echo " ${BOLD}-h${NORM}: Help - Show me this helpful message."
}

function check_http_status {
  http_status=`curl -s -o $1 -w "%{http_code}" $2`
  if [ $http_status != 200 ]; then
    echo $3
    exit 1
  fi
}

function check_app {
  app="${1}"
  app_status=`${app} -v`
  app_exit=$?
  if [ $app_exit != 0 ]; then
    echo "Your application may not have been properly installed."
    echo "Could not run \`${app} -v'"
    exit 1
  else
    echo "\`${app} -v' seems to be sane, yay: ${app_status}"
    exit 0
  fi
}

# Gather options from flags.
while getopts "hv:d:a:b:n:" opt; do
    case "$opt" in
    h)
        show_help
        exit 0
        ;;
    \?)
        show_help
        exit 0
        ;;
    v)
        VERSION=$OPTARG
        ;;
    d)
        DIRECTORY=$OPTARG
        ;;
    b)
        PROFILE=$OPTARG
        ;;
    n)
        APPLICATION=$OPTARG
        ;;
    a)
        ARCHITECTURE=$OPTARG
        ;;
    esac
done
shift $((OPTIND-1))

# Validate options and set defaults.
if [ -z "${APPLICATION}" ]; then
  echo "${BOLD}ERROR${NORM}: You must specify an application to install."
  echo ""
  show_help
  exit 1
else
  check_http_status '/dev/null' "https://releases.hashicorp.com/${APPLICATION}/" "${BOLD}ERROR${NORM}: ${APPLICATION} does not appear to exist. Please enter a valid application name."
fi

if [ -z "${VERSION}" ] || [ "${VERSION}" == "latest" ]; then
  VERSION=`curl -s https://releases.hashicorp.com/${APPLICATION}/ | grep -o "${APPLICATION}_[0-9].[0-9].[0-9]" | sort | tail -1 | sed s/${APPLICATION}_//`
else
  check_http_status '/dev/null' "https://releases.hashicorp.com/${APPLICATION}/${VERSION}/" "${BOLD}ERROR${NORM}: ${APPLICATION} ${VERSION} does not appear to exist. Please enter a valid application version."
fi

if [ -z "${ARCHITECTURE}" ]; then
  ARCHITECTURE=darwin_amd64
fi

if [ -z "${DIRECTORY}" ]; then
  DIRECTORY=/opt/${APPLICATION}
fi

# Try to create the application directory. If there is an error, ask the user to create it manually.
mkdir -p ${DIRECTORY} &>/dev/null
check_dir=`echo $?`
if [ "${check_dir}" -ne 0 ]; then
  echo -e "${BOLD}ERROR${NORM}: It appears ${DIRECTORY} does not exist and/or failed to create. Please run 'sudo mkdir ${DIRECTORY} && sudo chown $USER ${DIRECTORY}' then re-execute this script."
  exit 1
fi

# Download and extract the application.
echo "${BOLD}NOTICE${NORM}: Installing ${APPLICATION}_${VERSION}_${ARCHITECTURE} to ${DIRECTORY}"
cd ${DIRECTORY}
check_http_status "${APPLICATION}.zip" "https://releases.hashicorp.com/${APPLICATION}/${VERSION}/${APPLICATION}_${VERSION}_${ARCHITECTURE}.zip" "${BOLD}ERROR${NORM}: ${APPLICATION} ${VERSION} does not appear to exist. Please enter a valid application version."
unzip -o "${APPLICATION}.zip" &>/dev/null

# If user has specified a bash profile, update it and source it
if [ -z "${PROFILE}" ]; then
  echo "${BOLD}NOTICE${NORM}: ${APPLICATION} ${VERSION} has been successfully installed."
  echo "Remember to add 'PATH=/usr/local/${APPLICATION}/bin:${DIRECTORY}:\$PATH' to your bash profile if necessary."
  exit 0
else
  echo "Writing updated PATH to your bash profile..."
  echo "PATH=/usr/local/${APPLICATION}/bin:${DIRECTORY}:\$PATH" >> $HOME/.${PROFILE}
  . $HOME/.${PROFILE}
  check_app ${APPLICATION}
fi
