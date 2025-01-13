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
---

## Testing Images:

### _qlikr:8_:
```shell
# Run docker image:
docker run --rm --platform linux/amd64 -it docker.artifacts/qlikr:8

# Image command:
ls
```
```text
# Output:
bin  boot  dev  etc  home  lib  lib64  lost+found  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```
---
### _qlikr:8-core_:
```shell
# Run docker image:
docker run --rm --platform linux/amd64 -it docker.artifacts/qlikr:8-core
```
```text
# Output:
Image Versions
-------------------------------------------------------------------------------------------------
OS................: CentOS Linux 8
Python3...........: 3.6.8
-------------------------------------------------------------------------------------------------
SystemD...........: systemd 239 (239-51.el8_5.2)
unixODBC..........: 2.3.7
SQL-ODBC..........: ODBC for PostgreSQL ODBC for MySQL Free Sybase & MS SQL Driver ODBC for MariaDB Microsoft ODBC Driver 18 for SQL Server
Curl..............: 7.61.1 - 2018-09-05
Wget..............: GNU Wget 1.19.5 built on linux-gnu.
JQ................: jq-1.5
Bash..............: 4.4.20 (redhat-x86_64)
-------------------------------------------------------------------------------------------------
TimeZone..........: America/Chicago
DateTime..........: Sun Jan 12 10:19:25 CST 2025
-------------------------------------------------------------------------------------------------
```
```shell
# Image command:
ls
```
```text
# Output:
total 60
lrwxrwxrwx   1 root root    7 Jun 22  2021 bin -> usr/bin
dr-xr-xr-x   4 root root 4096 Jan 11 09:37 boot
-rw-r--r--   1 root root  323 Jan 12 10:19 currentVersions.json
drwxr-xr-x   5 root root  360 Jan 12 10:19 dev
-rwxr-xr-x   1 root root    0 Jan 12 10:19 .dockerenv
drwxr-xr-x   1 root root 4096 Jan 12 10:19 etc
drwxr-xr-x   2 root root 4096 Nov  3  2020 home
lrwxrwxrwx   1 root root    7 Jun 22  2021 lib -> usr/lib
lrwxrwxrwx   1 root root    9 Jun 22  2021 lib64 -> usr/lib64
drwx------   2 root root 4096 Sep 15  2021 lost+found
drwxr-xr-x   2 root root 4096 Nov  3  2020 media
drwxr-xr-x   2 root root 4096 Nov  3  2020 mnt
drwxr-xr-x   1 root root 4096 Jan 11 09:38 opt
dr-xr-xr-x 287 root root    0 Jan 12 10:19 proc
dr-xr-x---   1 root root 4096 Jun 22  2021 root
drwxr-xr-x   1 root root 4096 Jan 11 09:37 run
lrwxrwxrwx   1 root root    8 Jun 22  2021 sbin -> usr/sbin
drwxr-xr-x   2 root root 4096 Nov  3  2020 srv
dr-xr-xr-x  11 root root    0 Jan 12 10:19 sys
drwxrwxrwt   1 root root 4096 Jan 11 09:38 tmp
drwxr-xr-x   1 root root 4096 Jan 11 09:37 usr
drwxr-xr-x   1 root root 4096 Jan 11 09:37 var
-rwxr-xr-x   1 root root 3715 Jan  8 19:51 versionCheck.sh
```
---
### _qlikr:2023.11.0-720-core_:
```shell
# Run docker image:
docker run --rm --platform linux/amd64 -it docker.artifacts/qlikr:2023.11.0-720-core
```
```text
Image Versions
-------------------------------------------------------------------------------------------------
OS................: CentOS Linux 8
Python3...........: 3.6.8
-------------------------------------------------------------------------------------------------
SystemD...........: systemd 239 (239-51.el8_5.2)
unixODBC..........: 2.3.7
SQL-ODBC..........: ODBC for PostgreSQL ODBC for MySQL Free Sybase & MS SQL Driver ODBC for MariaDB Microsoft ODBC Driver 18 for SQL Server
Curl..............: 7.61.1 - 2018-09-05
Wget..............: GNU Wget 1.19.5 built on linux-gnu.
JQ................: jq-1.5
Bash..............: 4.4.20 (redhat-x86_64)
-------------------------------------------------------------------------------------------------
TimeZone..........: America/Chicago
DateTime..........: Sun Jan 12 10:19:25 CST 2025
-------------------------------------------------------------------------------------------------
```
```shell
# Image command:
ls
```
```shell
# Output:
total 60
lrwxrwxrwx   1 root root    7 Jun 22  2021 bin -> usr/bin
dr-xr-xr-x   4 root root 4096 Jan 11 09:37 boot
-rw-r--r--   1 root root  323 Jan 12 10:19 currentVersions.json
drwxr-xr-x   5 root root  360 Jan 12 10:19 dev
-rwxr-xr-x   1 root root    0 Jan 12 10:19 .dockerenv
drwxr-xr-x   1 root root 4096 Jan 12 10:19 etc
drwxr-xr-x   2 root root 4096 Nov  3  2020 home
lrwxrwxrwx   1 root root    7 Jun 22  2021 lib -> usr/lib
lrwxrwxrwx   1 root root    9 Jun 22  2021 lib64 -> usr/lib64
drwx------   2 root root 4096 Sep 15  2021 lost+found
drwxr-xr-x   2 root root 4096 Nov  3  2020 media
drwxr-xr-x   2 root root 4096 Nov  3  2020 mnt
drwxr-xr-x   1 root root 4096 Jan 11 09:38 opt
dr-xr-xr-x 287 root root    0 Jan 12 10:19 proc
dr-xr-x---   1 root root 4096 Jun 22  2021 root
drwxr-xr-x   1 root root 4096 Jan 11 09:37 run
lrwxrwxrwx   1 root root    8 Jun 22  2021 sbin -> usr/sbin
drwxr-xr-x   2 root root 4096 Nov  3  2020 srv
dr-xr-xr-x  11 root root    0 Jan 12 10:19 sys
drwxrwxrwt   1 root root 4096 Jan 11 09:38 tmp
drwxr-xr-x   1 root root 4096 Jan 11 09:37 usr
drwxr-xr-x   1 root root 4096 Jan 11 09:37 var
-rwxr-xr-x   1 root root 3715 Jan  8 19:51 versionCheck.sh
```
```shell
# Image command:
ls /opt/attunity/replicate/bin
```
```text
# Output:
total 75696
-rwxrwxr-x 1 attunity attunity 68834963 Aug 15 11:54 arepbq
-rwxrwxr-x 1 attunity attunity   155360 Aug 15 11:54 arep_csv2prq
-rwxrwxr-x 1 attunity attunity     2259 Aug 15 11:54 arep_login.sh
-rwxrwxr-x 1 attunity attunity    13882 Aug 15 11:54 arep.sh
-rwxrwxr-x 1 attunity attunity     1487 Aug 15 11:54 fix_permissions
-rwxrwxr-x 1 attunity attunity  3955630 Aug 15 11:54 irpcd
-rwxrwxr-x 1 attunity attunity  1239688 Aug 15 11:54 kdestroy
-rwxrwxr-x 1 attunity attunity  1999928 Aug 15 11:54 kinit
-rwxrwxr-x 1 attunity attunity  1253656 Aug 15 11:54 klist
-rwxrwxr-x 1 attunity attunity     7226 Aug 15 11:54 nav_util
-rwxrwxr-x 1 attunity attunity    15248 Aug 15 11:54 repctl
-rwxrwxr-x 1 attunity attunity      789 Aug 15 11:54 repctl.cfg
-rwxrwxr-x 1 attunity attunity      290 Aug 15 11:54 repctl.sh
-rw-r--r-- 1 attunity attunity       36 Jan 11 09:38 site_arep_login.sh
```
---
### _qlikr:2023.11.0-720_:
```shell
# Run docker image:
./run_docker.sh 3552 docker.artifacts/qlikr:2023.11.0-720 AB1gL0ngPa33w0rd
```
```shell
# Stop & Remove Container:
docker stop qlikr && docker rm $_
```
#### Test Qlik Replicate:
**_url:_** https://127.0.0.1:3552/attunityreplicate/  
**_user:_** admin  
**_pw:_** AB1gL0ngPa33w0rd  