#!/bin/bash
#Here we specified the different version of each script

#Software version number

qupath_version=0.4.3
abba_extension_version=0.1.4
elastix_version=5.1.0
biop_extension_version=2.0.0
cellpose_extension_version=0.6.1
warpy_extension_version=0.2.0
stardist_extension_version=0.4.0
biop_omero_extension_version=0.3.2
warpy_extension_version=0.2.0

#QuPath arguments :
argQuPathUserPath="defaultQuPathUserPath=\"$path_install/QuPath_Common_Data_0.4\""
argQuPathPrefNode="quPathPrefsNode=\"io.github.qupath/0.4\""
argQuPathExtensionURL="quPathExtensionURL=\"$qupath_abba_extension_url\""
argQuitAfterInstall="quitAfterInstall=\"true\""