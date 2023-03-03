#!/bin/bash
# Here we specified the different version of each script

# Software version number

qupath_version=0.4.3 # https://github.com/qupath/qupath/releases
abba_extension_version=0.1.4 # https://github.com/BIOP/qupath-extension-abba/releases
elastix_version=5.0.1 # https://github.com/SuperElastix/elastix/releases
biop_extension_version=2.0.0 # https://github.com/BIOP/qupath-extension-biop/releases
cellpose_extension_version=0.6.1 # https://github.com/BIOP/qupath-extension-cellpose/releases
warpy_extension_version=0.2.0 # https://github.com/BIOP/qupath-extension-warpy/releases
stardist_extension_version=0.4.0 # https://github.com/qupath/qupath-extension-stardist/releases
biop_omero_extension_version=0.3.2 # https://github.com/BIOP/qupath-extension-biop-omero/releases

# Releases URL
# QuPath Extensions
warpy_extension_url="https://github.com/BIOP/qupath-extension-warpy/releases/download/${warpy_extension_version}/qupath-extension-warpy-${warpy_extension_version}.zip"
abba_extension_url="https://github.com/BIOP/qupath-extension-abba/releases/download/${abba_extension_version}/qupath-extension-abba-${abba_extension_version}.zip"
biop_extension_url="https://github.com/BIOP/qupath-extension-biop/releases/download/v${biop_extension_version}/qupath-extension-biop-${biop_extension_version}.jar"
cellpose_extension_url="https://github.com/BIOP/qupath-extension-cellpose/releases/download/v${cellpose_extension_version}/qupath-extension-cellpose-${cellpose_extension_version}.zip"
warpy_extension_url="https://github.com/BIOP/qupath-extension-warpy/releases/download/${warpy_extension_version}/qupath-extension-warpy-${warpy_extension_version}.zip"
abba_extension_url="https://github.com/BIOP/qupath-extension-abba/releases/download/${abba_extension_version}/qupath-extension-abba-${abba_extension_version}.zip"
stardist_extension_url="https://github.com/qupath/qupath-extension-stardist/releases/download/v${stardist_extension_version}/qupath-extension-stardist-${stardist_extension_version}.jar"
biop_omero_extension_url="https://github.com/BIOP/qupath-extension-biop-omero/releases/download/v${biop_omero_extension_version}/qupath-extension-biop-omero-${biop_omero_extension_version}.zip"

# QuPath Scripts
biop_qupath_scripts_url="https://github.com/BIOP/qupath-scripts/archive/refs/heads/main.zip"

# QuPath arguments :
argQuPathUserPath="defaultQuPathUserPath=\"$path_install/QuPath_Common_Data_0.4\""
argQuPathPrefNode="quPathPrefsNode=\"io.github.qupath/0.4\""
# argQuPathExtensionURL="quPathExtensionURL=\"$qupath_abba_extension_url\"" <- it depends
argQuitAfterInstall="quitAfterInstall=\"true\""