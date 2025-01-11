#!/bin/bash

# set variables
declare -r TRUE=0
declare -r FALSE=1

##################################################################
# Purpose: Converts a string to lower case
# Arguments:
#   $1 -> String to convert to lower case
##################################################################
function to_lower()
{
    local str=("$@")
    local output
    output=$(tr '[:upper:]' '[:lower:]'<<<"${str[@]}")
    echo "${output}"
}

function to_upper()
{
    local str=("$@")
    local output
    output=$(tr '[:lower:]' '[:upper:]'<<<"${str[@]}")
    echo "${output}"
}

##################################################################
# Purpose: Return true if script is executed by the root user
# Arguments: none
# Return: True (0) or False (1)
##################################################################
function is_root()
{
   [ "$(id -u)" -eq 0 ] && echo $TRUE || echo $FALSE
}

function get_bashVersion()
{
  echo "$(bash --version | grep "bash" | cut -f 4 -d " " | cut -d "-" -f 1  | cut -d "(" -f 1)"
}

function get_bashPlatform()
{
  echo "$(bash --version | grep "bash" | cut -f 5 -d " " | cut -f 1 -d "-" | cut -d "(" -f 2)"
}

function get_bashVendor()
{
  echo "$(bash --version | grep "bash" | cut -f 5 -d " " | cut -f 2 -d "-" | cut -d "(" -f 2)"
}

function get_pythonVersion()
{
  if hash python 2>/dev/null; then
    echo "$(python -c 'import platform; print(platform.python_version())')"
  else
    echo "not installed"
  fi
}

function get_python3Version()
{
  if hash python3 2>/dev/null; then
    echo "$(python3 -c 'import platform; print(platform.python_version())')"
  else
    echo "not installed"
  fi
}

function get_jqVersion()
{
   if hash jq 2>/dev/null; then
    echo "$(jq --version)"
  else
    echo "not installed"
  fi

}


# generate build days from project start date
# ----------------------------------------------------
function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }
function get_appDays()
{
  if [ "${bashVendor}" == "apple" ]; then
    # use new bash date format
    seconds_start=$(date -j -f '%d-%b-%Y' "$1" "+%s")
  else
    # use old bash date format
    seconds_start=$(date -d "$1 00:00:00" +"%s")
  fi

  local seconds_now=$(date +%s)
  local seconds_diff=$((seconds_now-seconds_start))
  echo $((seconds_diff/(3600*24)))
}

function parse_yaml()
{
   local prefix=$2
   local filepath=$1
   local s='[[:space:]]*'
   local w='[a-zA-Z0-9_]*'
   local fs="$(echo @|tr @ '\034')"

   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:${s}[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  "${filepath}" |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'"${prefix}"'",vn, $2, $3);
      }
   }'
}

function read_artifactoryYaml()
{
  file="./artifactory/_repository.yaml"

  if [ -e "$file" ]; then
    eval "$(parse_yaml $file)"
    app_Appcode=${repo_appcode}
    app_Name=${repo_name}
    app_Description=${repo_description}
    app_VCS=${repo_vcs}
    app_Vendor=${repo_vendor}
    app_StartDate=${repo_startdate}
  else
    app_Appcode="{APPCODE}"
    app_Name="{APPNAME}"
    app_Description="{APPDESCRIPTION}"
    app_VCS="{VCS_URL}"
    app_Vendor="Regions"
    app_StartDate="01-Jan-2001"
  fi
}


function read_versionYaml()
{
  file="./artifactory/_repository.yaml"
  if [ -e "$file" ]; then
    eval "$(parse_yaml ./artifactory/_repository.yaml "ver_")"
    app_Version=${repo_version}
    sv=($(echo "$app_Version" | tr '.' '\n'))
    app_Version_major=${sv[0]}
    app_Version_minor=${sv[1]}
    app_Version_patch=${sv[2]}
  else
    app_Version="2023.0.0"
    app_Version_major="2023"
    app_Version_minor="0"
    app_Version_patch="0"
  fi
}

read_artifactoryYaml
read_versionYaml

#echo "Version............: ${app_Version}"
#echo "  Major............: ${app_Version_major}"
#echo "  Minor............: ${app_Version_minor}"
#echo "  Patch............: ${app_Version_patch}"
#
#echo "AppCode............: ${app_Appcode}"
#echo "Name...............: ${app_Name}"
#echo "Description........: ${app_Description}"
#echo "VCS................: ${app_VCS}"
#echo "Vendor.............: ${app_Vendor}"
#echo "StartDate..........: ${app_StartDate}"
#
#
#echo "is_root............: $(is_root)"
#echo "to_lower...........: $(to_lower QWERTY)"
#echo "to_upper...........: $(to_upper qwerty)"
#echo "get_bashVersion....: $(get_bashVersion)"
#echo "get_bashPlatform...: $(get_bashPlatform)"
#echo "get_bashVendor.....: $(get_bashVendor)"
#echo "Python Version.....: $(get_pythonVersion)"
#echo "Python3 Version....: $(get_python3Version)"
#echo "App Days...........: $(get_appDays "${app_StartDate}")"
