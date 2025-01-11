#!/bin/bash
# e - exit when any command fails
set -e

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. scripts/buildFunctions.sh

# Variables: Must be setup or defaults set
# --------------------------------------------------------------------------------------------
artifactory_Server=${DOCKER_REGISTRY:-'docker.artifacts'}
artifactory_Repository=${DOCKER_REPO:-'qlikr'}
# --------------------------------------------------------------------------------------------
# Docker file from param
buildDockerfile="${1}.Dockerfile"
buildPythonVersion="${1}"

# Check if the Dockerfile exists
if [ ! -f "${buildDockerfile}" ]; then
  echo "Dockerfile does not exist: ${buildDockerfile}"
  exit 1 # Exit the script with an error code if the file is missing
fi
# --------------------------------------------------------------------------------------------
read_artifactoryYaml    ##function to read _artifactory.yaml to get image tags

bashVersion=$(get_bashVersion)
bashPlatform=$(get_bashPlatform)
bashVendor=$(get_bashVendor)
pythonVersion=$(get_pythonVersion)
python3Version=$(get_python3Version)
jqVersion=$(get_jqVersion)
app_Version_days=$(get_appDays "${app_StartDate}")
app_buildDate="${bamboo_buildTimeStamp:-$(date)}"
app_buildNumber="${BUILD_NUMBER:-0}"
app_buildJobName="${GITHUB_JOB:-LOCAL}"
app_repositoryGitBranch="${GIT_BRANCH:-develop}"
artifactory_SourceRepository="${artifactory_Repository}"
artifactory_Image="${artifactory_Server}/${artifactory_SourceRepository}"

artifactory_tagLatest="${buildPythonVersion}"

echo "Build Image: ${buildDockerfile}"
echo "------------------------------------------------------------------------------------------------------------------------"
echo "Build Date.........................................: ${app_buildDate}"
echo "Build Number.......................................: ${app_buildNumber}"
echo "------------------------------------------------------------------------------------------------------------------------"
echo "Artifactory Server.................................: ${artifactory_Server}"
echo "Artifactory Repo...................................: ${artifactory_SourceRepository}"
echo "Artifactory Image..................................: ${artifactory_Image}"
echo "Artifactory Tag - Latest...........................: ${artifactory_tagLatest}"
echo "------------------------------------------------------------------------------------------------------------------------"
echo "Bash Version.......................................: ${bashVersion}"
echo "Bash Platform......................................: ${bashVendor}-${bashPlatform}"
echo "Python Version.....................................: ${pythonVersion}"
echo "Python3 Version....................................: ${python3Version}"
echo "jq Version.........................................: ${jqVersion}"
echo "Script Path........................................: ${SCRIPTPATH}"
echo "------------------------------------------------------------------------------------------------------------------------"
echo "Version Variables:"
echo "App Start..........................................: ${app_StartDate}"
echo "      Dockerfile...................................: ${buildPythonVersion}.Dockerfile"
echo "Version............................................: ${app_Version}"
echo "      Major........................................: ${app_Version_major}"
echo "      Minor........................................: ${app_Version_minor}"
echo "      Patch........................................: ${app_Version_patch}"
echo "App Days...........................................: ${app_Version_days}"
echo "------------------------------------------------------------------------------------------------------------------------"
echo "Docker/Artifactory Image Label Variables: _repository.json & _package.json"
echo "  -arg APPCODE.....................................: ${app_Appcode}"
echo "  -arg NAME........................................: ${app_Name}"
echo "  -arg DESCRIPTION.................................: ${app_Description}"
echo "  -arg VCS.........................................: ${app_VCS}"
echo "  -arg VENDOR......................................: ${app_Vendor}"
echo "  -arg BUILD_DATE..................................: ${app_buildDate}"
echo "  -arg BUILD_NUMBER................................: ${app_buildNumber}"
echo "  -arg GIT_BRANCH..................................: ${app_repositoryGitBranch}"
echo "  -arg JOB_NAME....................................: ${app_buildJobName}"
echo "  -arg APP_VERSION.................................: ${app_Version}"
echo "------------------------------------------------------------------------------------------------------------------------"

echo ""
echo "Building Docker Image: ${artifactory_Image}:${artifactory_tagLatest}"
echo "------------------------------------------------------------------------------------------------------------------------"
docker build --no-cache --platform linux/amd64 --force-rm \
  --build-arg APPCODE="${app_Appcode}" \
  -t "${artifactory_Image}":"${artifactory_tagLatest}" -f "${buildDockerfile}" .

export DOCKER_IMAGE="${artifactory_Image}:${artifactory_tagLatest}"
if [ "${app_buildJobName}" != 'LOCAL' ]; then
  echo "DOCKER_IMAGE=$DOCKER_IMAGE" >> "$GITHUB_ENV"
fi

