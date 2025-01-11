# Q-Replicate
Sample to create Qlik-Replicate base image to run in OpenShift

## Project Structure:

- **_.Qlik_**
  - Original files supplied by Qlik to build docker image
- **_packages_**
  - Versions of packages used to build the images
    - `*_fileMerge.py` and `*_fileSplit.py` files are used to split/merge package so it can be stored in GitHub
    - `msodbcsql18-18.2.2.1-1.x86_64.rpm` - MsSql ODBC Driver
    - `mssql-tools18-18.2.1.1-1.x86_64.rpm` - MsSql Tools
    - `snowflake-odbc-3.1.1.x86_64.rpm` - SnowFlake ODBC Driver
    - `areplicate-2023.11.0-720_bin-??.byte` - Split version of `areplicate-2023.11.0-720x86_64.rpm`
    - `areplicate-2024.5.0-144_bin-??.byte` - Split version of `areplicate-2024.5.0-144x86_64.rpm`
- **_artifactory_**
  - Repository configuration file
    - Modify as needed to add repo info to image
- **_scripts_**
  - These scripts enhance the automation and consistency of the CI/CD pipeline
    - `build.sh` for Docker image creation with metadata
    - `buildFunctions.sh` for reusable utility functions
    - `versionCheck.sh` for environment version checks
- **_root files_**
  - These streamline deployment and configuration processes
    - `run_docker.sh` for running Docker containers with specified configurations
    - `start_replicate.sh` for initializing and configuring Attunity Replicate
    - `license.json` file to manage licensing details

## Dockerfile Build Order:
### _8.dockerfile_:
  Using the latest _**centos:latest**_ image. Modified repository configuration to use vault.centos.org for stability. Included commands to update system packages and clean cache.
  ```shell
    > ./scripts/build.sh 8
    > docker images
    
  # Output
  REPOSITORY               TAG                  IMAGE ID       CREATED              SIZE
  docker.artifacts/qlikr   8                    dab5f76fb5cd   1 minute ago         176MB
  ```
---
### _8-core.dockerfile:_
  - Using the latest _**docker.artifacts/qlikr:8**_ image. It installs required tools, Python, and SQL drivers, and includes a version check script for runtime verification.
  ```shell
    > ./scripts/build.sh 8-core
    > docker images
    
  # Output
  REPOSITORY               TAG                  IMAGE ID       CREATED              SIZE
  docker.artifacts/qlikr   8-core               e44f51140bc3   1 minute ago         187MB
  docker.artifacts/qlikr   8                    dab5f76fb5cd   2 minutes ago        176MB
  ```
---
### _2023.11.0-720-core.dockerfile:_
  - Using the latest _**docker.artifacts/qlikr:8-core**_ image. Sets up the environment for version _**Replicate 2023.11.0-720**_. It updates repository configurations, installs necessary packages, and includes the areplicate setup process. Environment variables are also updated.
  ```shell
    > ./scripts/build.sh 2023.11.0-720-core
    > docker images
    
  # Output
  REPOSITORY               TAG                  IMAGE ID       CREATED              SIZE
  docker.artifacts/qlikr   2023.11.0-720-core   6556a686c97d   1 minute ago         983MB
  docker.artifacts/qlikr   8-core               e44f51140bc3   2 minutes ago        187MB
  docker.artifacts/qlikr   8                    dab5f76fb5cd   3 minutes ago        176MB
  ```
---
### _2023.11.0-720.dockerfile:_
  - Based on the _**2023.11.0-720-core**_ image. Installs necessary packages, and sets up environment variables for Qlik Replicate. Additionally, it includes scripts and license setup for container initialization.
  ```shell
    > ./scripts/build.sh 2023.11.0-720
    > docker images
    
  # Output
  REPOSITORY               TAG                  IMAGE ID       CREATED              SIZE
  docker.artifacts/qlikr   2023.11.0-720        ea687cc739ee   1 minute  ago        990MB
  docker.artifacts/qlikr   2023.11.0-720-core   6556a686c97d   2 minutes ago        983MB
  docker.artifacts/qlikr   8-core               e44f51140bc3   3 minutes ago        187MB
  docker.artifacts/qlikr   8                    dab5f76fb5cd   4 minutes ago        176MB
  ```
---
### _2024.5.0-144.dockerfile:_
  - This has not been used yet. It will need a core base image created. Use _**2023.11.0-720-core.Dockerfile**_ as an example.
