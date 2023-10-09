#!/bin/bash
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    scriptpath=$(realpath $(dirname $0))
elif [[ "$OSTYPE" == "darwin"* ]]; then
    scriptpath=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
elif [[ "$OSTYPE" == "msys" ]]; then
    scriptpath=$(realpath $(dirname $0))
fi
source "$scriptpath/global_function.sh"
source "$scriptpath/version_software_script.sh"

################################################################################
# Help                                                                         #
################################################################################
function Help()
{
   # Display Help
   echo ------QuPath extensions installer Script -------------
   echo "This bash file downloads and install some biop selected QuPath (v$qupath_version) extensions."
   echo 
   echo "  - https://github.com/BIOP/qupath-extension-biop"
   echo "  - https://github.com/BIOP/qupath-extension-cellpose"
   echo "  - https://github.com/BIOP/qupath-extension-warpy"
   echo "  - https://github.com/BIOP/qupath-extension-abba"
   echo "  - https://github.com/qupath/qupath-extension-stardist"
   echo "  - https://github.com/BIOP/qupath-extension-biop-omero"
   echo
   echo "You should specify the folder where qupath is installed"
   echo "argument of this script. For instance: "
   echo ""
   echo "Windows:"
   echo "./install_qupath_extensions.sh \"C:/\""
   echo 
   echo "Mac:"
   echo "./install_qupath_extensions.sh /Applications/"
   echo ""
   echo "If no path is specified, you will be asked for one."
   echo
}

while getopts ":h" option; do
   case $option in
      h) # display Help
         Help
         exit;;
   esac
done


# ----------------- COMPONENTS VERSION -----------
biop_extension_url="https://github.com/BIOP/qupath-extension-biop/releases/download/v${biop_extension_version}/qupath-extension-biop-${biop_extension_version}.jar"

cellpose_extension_url="https://github.com/BIOP/qupath-extension-cellpose/releases/download/v${cellpose_extension_version}/qupath-extension-cellpose-${cellpose_extension_version}.zip"

warpy_extension_url="https://github.com/BIOP/qupath-extension-warpy/releases/download/${warpy_extension_version}/qupath-extension-warpy-${warpy_extension_version}.zip"

abba_extension_url="https://github.com/BIOP/qupath-extension-abba/releases/download/${abba_extension_version}/qupath-extension-abba-${abba_extension_version}.zip"

stardist_extension_url="https://github.com/qupath/qupath-extension-stardist/releases/download/v${stardist_extension_version}/qupath-extension-stardist-${stardist_extension_version}.jar"

biop_omero_extension_url="https://github.com/BIOP/qupath-extension-biop-omero/releases/download/v${biop_omero_extension_version}/qupath-extension-biop-omero-${biop_omero_extension_version}.zip"

# ----------------- MAIN --------------------------

echo ------ QuPath extensions Installer Script -------------
echo "This batch file downloads and install QuPath extensions"

echo 
echo "- QuPath version: $qupath_version"
echo
echo "- BIOP Extension: $biop_extension_version"
echo "- CellPose Extension: $cellpose_extension_version"
echo "- Warpy Extension: $warpy_extension_version"
echo "- ABBA Extension: $abba_extension_version"
echo "- Stardist Extension: $stardist_extension_version"
echo "- BIOP OMERO Extension: $biop_omero_extension_version"

#  ------- INSTALLATION PATH VALIDATION and Check system if not already done
if [ $# -eq 0 ] 
then
	path_validation
else 	
	path_validation $1
fi


# ------ Getting IMAGEJ/FIJI
echo "------ Is ImageJ/Fiji installed ? ------"
echo ------ Setting up ImageJ/Fiji ------
. "$scriptpath/install_fiji.sh" "$path_install"
fiji_path="$path_install/Fiji.app/$fiji_executable_file"

if [[ -f "$fiji_path" ]]; then
    echo "Fiji correctly detected."
else
	echo "Fiji is not installed, please install it before running this script"
	echo "Fiji is not in $fiji_path"
	pause "Press [Enter] to end the script"
	exit 1 # We cannot proceed
fi

# ------ SETTING UP QUPATH ------
echo ------ Setting up QuPath ------

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	echo "Linux beta supported - please contribute to this installer to support it!"
	qupath_executable_file="QuPath"
	qupath_path="$path_install/QuPath/bin/$qupath_executable_file"
elif [[ "$OSTYPE" == "darwin"* ]]; then
	qupath_executable_file="Contents/MacOS/QuPath"
	qupath_path="/Applications/QuPath.app/$qupath_executable_file"
elif [[ "$OSTYPE" == "msys" ]]; then
	qupath_executable_file="QuPath-$qupath_version.exe"
	qupath_path="$path_install/QuPath-$qupath_version/$qupath_executable_file"
fi

if [[ -f "$qupath_path" ]]; then
		echo "QuPath correctly detected"
	else
		echo "QuPath is not installed, please install it before running this script"
		echo "Please check this directory : $qupath_path"
		pause "Press [Enter] to end the script"
		exit 1 # We cannot proceed
	fi	

echo ------ Setting up QuPath extension ------

# See https://imagej.net/scripting/headless to deal with the mess of single quotes vs double quotes

echo "--- Installing BIOP extension"
argQuPathExtensionURL="quPathExtensionURL=\"$biop_extension_url\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathExtensionURL,$argQuitAfterInstall"
"$fiji_path" --ij2 --headless --run InstallQuPathExtension.groovy "$all_args"

echo "--- Installing Cellpose extension"
argQuPathExtensionURL="quPathExtensionURL=\"$cellpose_extension_url\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathExtensionURL,$argQuitAfterInstall"
"$fiji_path" --ij2 --headless --run InstallQuPathExtension.groovy "$all_args"

echo "--- Installing Warpy extension"

argQuPathExtensionURL="quPathExtensionURL=\"$warpy_extension_url\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathExtensionURL,$argQuitAfterInstall"
"$fiji_path" --ij2 --headless --run InstallQuPathExtension.groovy "$all_args"

echo "--- Installing ABBA extension"

argQuPathExtensionURL="quPathExtensionURL=\"$abba_extension_url\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathExtensionURL,$argQuitAfterInstall"
echo "$all_args"
"$fiji_path" --ij2 --headless --run InstallQuPathExtension.groovy "$all_args"

echo "--- Installing Stardist extension"

argQuPathExtensionURL="quPathExtensionURL=\"$stardist_extension_url\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathExtensionURL,$argQuitAfterInstall"
echo "$all_args"
"$fiji_path" --ij2 --headless --run InstallQuPathExtension.groovy "$all_args"

echo "--- Installing Stardist extension"

argQuPathExtensionURL="quPathExtensionURL=\"$biop_omero_extension_url\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathExtensionURL,$argQuitAfterInstall"
echo "$all_args"
"$fiji_path" --ij2 --headless --run InstallQuPathExtension.groovy "$all_args"

echo -------- INSTALLATION OF OMERO DEPENDENCIES ---------

biop_omero_dependencies_url="https://github.com/ome/openmicroscopy/releases/download/v5.6.6/OMERO.java-5.6.6-ice36.zip"

argQuPathExtensionURL="quPathExtensionURL=\"$biop_omero_dependencies_url\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathExtensionURL,$argQuitAfterInstall"
echo "$all_args"
"$fiji_path" --ij2 --headless --run InstallQuPathExtension.groovy "$all_args"

echo -------- INSTALLATION OF QUPATH BIOP SHARED SCRIPTS ---------

biop_qupath_scripts_url="https://github.com/BIOP/qupath-scripts/archive/refs/heads/main.zip"

argQuPathScriptsURL="quPathScriptsURL=\"$biop_qupath_scripts_url\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathScriptsURL,$argQuitAfterInstall"
echo "$all_args"
"$fiji_path" --ij2 --headless --run InstallQuPathScripts.groovy "$all_args"

echo ------ INSTALLATION DONE ------
