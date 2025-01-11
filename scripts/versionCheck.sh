#!/bin/bash

function get_bashVersion() {
  echo "$(bash --version | grep 'bash' | cut -f 4 -d ' ' | cut -d '-' -f 1  | cut -d '(' -f 1)"
}

function get_bashPlatform() {
  echo "$(bash --version | grep 'bash' | cut -f 5 -d ' ' | cut -f 1 -d '-' | cut -d '(' -f 2)"
}

function get_bashVendor() {
  echo "$(bash --version | grep 'bash' | cut -f 5 -d ' ' | cut -f 2 -d '-' | cut -d '(' -f 2)"
}

function get_osVersion() {
  echo "$(cat etc/os-release | grep 'PRETTY' | cut -d '"' -f 2)"
}

function get_python3Version()
{
  if hash python3 2>/dev/null; then
    echo $(python3 -c 'import platform; print(platform.python_version())')
  else
    echo "not installed"
  fi
}

function get_odbcDriver() {
#  file="/opt/homebrew/etc/odbcinst.ini"
  file=$(odbcinst -j | grep "DRIVER" | cut -d ":" -f 2)

  if hash odbcinst 2>/dev/null; then
    echo $(cat ${file} | grep "Description" | cut -d "=" -f 2)
  else
    echo "not installed"
  fi
}

function get_unixODBC_Version() {
  if hash odbcinst 2>/dev/null; then
    echo $(odbcinst --version | sed '1p;d' | cut -d ' ' -f 2)
  else
    echo "not installed"
  fi
}

function get_osVersion() {
  file="../etc/os-release"
  if [ -e ../etc/os-release ]; then
    echo $(cat ../etc/os-release | grep "PRETTY" | cut -d '"' -f 2)
  else
    echo "os-release not found"
  fi
}

function get_CurlVersion() {
  if hash curl 2>/dev/null; then
    echo $(curl --version | sed '1p;d' | cut -d ' ' -f 2)
  else
    echo "not installed"
  fi
}

function get_CurlRelease() {
  if hash curl 2>/dev/null; then
    echo $(curl --version | sed '2p;d' | cut -d ' ' -f 2)
  else
    echo "not installed"
  fi
}

function get_WgetVersion() {
  if hash wget 2>/dev/null; then
    echo $(wget --version | sed '1p;d')
  else
    echo "not installed"
  fi
}

function get_SystemD() {
  if command -v systemctl &>/dev/null; then
    echo $(systemctl --version | sed '1p;d' | cut -d 'f' -f 2)
  else
    echo "not installed"
  fi
}

function get_gdebiVersion() {
  if command -v gdebi &>/dev/null; then
    echo $(gdebi --version)
  else
    echo "not installed"
  fi
}

function get_jqVersion() {
  if command -v jq &>/dev/null; then
    echo $(jq --version)
  else
    echo "not installed"
  fi
}


echo ""
echo "Image Versions"
echo "-------------------------------------------------------------------------------------------------"
echo "OS................: $(get_osVersion)"
echo "Python3...........: $(get_python3Version)"
echo "-------------------------------------------------------------------------------------------------"
echo "SystemD...........: $(get_SystemD)"
echo "unixODBC..........: $(get_unixODBC_Version)"
echo "SQL-ODBC..........: $(get_odbcDriver)"
echo "Curl..............: $(get_CurlVersion) - $(get_CurlRelease)"
echo "Wget..............: $(get_WgetVersion)"
echo "JQ................: $(get_jqVersion)"
echo "Bash..............: $(get_bashVersion) ($(get_bashVendor)-$(get_bashPlatform))"
echo "-------------------------------------------------------------------------------------------------"
echo "TimeZone..........: ${TZ:-not set}"
echo "DateTime..........: $(date)"
echo "-------------------------------------------------------------------------------------------------"
echo ""

jq -n \
  --arg OS "$(get_osVersion)" \
  --arg python3 "$(get_python3Version)" \
  --arg sqlODBC "$(get_odbcDriver)" \
  --arg curl "$(get_CurlVersion) - $(get_CurlRelease)" \
  --arg wget "$(get_WgetVersion)" \
  --arg jq "$(get_jqVersion)" \
  --arg bash "$(get_bashVersion) ($(get_bashVendor)-$(get_bashPlatform))" \
'
.OS = $OS |
.python3 = $python3 |
.sqlODBC = $sqlODBC |
.curl = $curl |
.wget = $wget |
.jq = $jq |
.bash = $bash
' > currentVersions.json

[ -z "${ZSH}" ] && bash