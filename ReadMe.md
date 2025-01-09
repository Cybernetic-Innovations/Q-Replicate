# Q-Replicate
Sample to create Qlik-Replicate base image to run in OpenShift

## Project Structure:

- **_.Qlik_**
  - Original files supplied by Qlik to build docker image
- **_packages_**
  - Versions of packages used to build the images
    - The *_fileMerge, *_fileSplit.py files are used to split/merge package so it can be stored in GitHub