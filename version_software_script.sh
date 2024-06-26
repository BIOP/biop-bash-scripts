#!/bin/bash
#Here we specified the different version of each script

#Software version number

qupath_version=0.5.1
abba_extension_version=0.3.1
elastix_version=5.0.1
biop_extension_version=3.1.0
cellpose_extension_version=0.9.3
warpy_extension_version=0.3.1
stardist_extension_version=0.5.0
biop_omero_extension_version=1.0.0
omero_ij_version=5.9.0

#QuPath arguments :
argQuPathUserPath="defaultQuPathUserPath=\"$path_install/QuPath_Common_Data_0.5\""
argQuPathPrefNode="quPathPrefsNode=\"io.github.qupath/0.5\""
argQuPathExtensionURL="quPathExtensionURL=\"$qupath_abba_extension_url\""
argQuitAfterInstall="quitAfterInstall=\"true\""
