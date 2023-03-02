#!/bin/bash
scriptpath= dirname $0
source "$scriptpath/version_software_script.sh"

################################################################################
# Help                                                                         #
################################################################################
function Help()
{
   # Display Help
   echo ------QuPath extensions installer Script -------------
   echo "This batch file downloads and install some biop selected QuPath (v0.4) extensions."
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


# ----------------- FUNCTIONS -------------------

# Wait for user 
function pause(){
   read -p "$*"
}

# Returns
function getuserdir(){
    local  __resultvar=$1
	local  myresult=
		while true ; do
			read -r -p "Path: " myresult
			if [ -d "$myresult" ] ; then
				break
			fi
			echo "$myresult is not a directory... try without slash at the end (unless it's the root drive like C:/)"
		done
    eval $__resultvar="'$myresult'"
}

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
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	echo "Your OS: Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Your OS: Mac OSX"
elif [[ "$OSTYPE" == "msys" ]]; then
    echo "Your OS: Windows"
else
    echo "Unknown OS, the script will exit: $OSTYPE"
	pause "Press [Enter] to end the script"
	exit 1 # We cannot proceed
fi
echo 
echo "- QuPath version: $qupath_version"
echo
echo "- BIOP Extension: $biop_extension_version"
echo "- CellPose Extension: $cellpose_extension_version"
echo "- Warpy Extension: $warpy_extension_version"
echo "- ABBA Extension: $abba_extension_version"
echo "- Stardist Extension: $stardist_extension_version"
echo "- BIOP OMERO Extension: $biop_omero_extension_version"

# ------- INSTALLATION PATH VALIDATION

echo ------- Installation path validation

if [ $# -eq 0 ] 
then
	echo "Please enter the installation path (windows: C:/, mac: /Applications/, Linux : /home/user/abba) \n
	The directory must exist first."
	getuserdir path_install
else 	
	if [ -d "$1" ] ; then
		path_install=$1
	else
		echo $1 is not a valid path
		echo "Please enter the installation path"
		getuserdir path_install
	fi	
fi

echo "All components will be installed in:"
echo "$path_install"


# ------ Getting IMAGEJ/FIJI
echo "------ Is ImageJ/Fiji installed ? ------"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	echo "Linux beta supported - please contribute to this installer to support it!"
	fiji_executable_file="ImageJ-linux64"
	fiji_url="https://downloads.imagej.net/fiji/latest/fiji-linux64.zip"
elif [[ "$OSTYPE" == "darwin"* ]]; then
	fiji_executable_file="Contents/MacOS/ImageJ-macosx"
	fiji_url="https://downloads.imagej.net/fiji/latest/fiji-macosx.zip"
elif [[ "$OSTYPE" == "msys" ]]; then
	fiji_executable_file="ImageJ-win64.exe"
	fiji_url="https://downloads.imagej.net/fiji/latest/fiji-win64.zip"
fi
fiji_path="$path_install/Fiji.app/$fiji_executable_file"

if [[ -f "$fiji_path" ]]; then
    echo "Fiji correctly detected."
else
	echo "Fiji is not installed, please install it before running this script"
	pause "Press [Enter] to end the script"
	exit 1 # We cannot proceed
fi


# ------ SETTING UP QUPATH ------
echo ------ Setting up QuPath ------

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	echo "Linux beta supported - please contribute to this installer to support it!"
	qupath_executable_file="QuPath"
	qupath_path="$path_install/QuPath-${qupath_version}/bin/$qupath_executable_file"
elif [[ "$OSTYPE" == "darwin"* ]]; then
	qupath_executable_file="Contents/MacOS/QuPath"
	qupath_path="/Applications/QuPath.app/$qupath_executable_file"
elif [[ "$OSTYPE" == "msys" ]]; then
	qupath_executable_file="QuPath-${qupath_version}.exe"
	qupath_path="$path_install/QuPath-${qupath_version}/$qupath_executable_file"
fi

if [[ -f "$qupath_path" ]]; then
		echo "QuPath correctly detected"
	else
		echo "QuPath is not installed, please install it before running this script"
		pause "Press [Enter] to end the script"
		exit 1 # We cannot proceed
	fi	

echo ------ Setting up QuPath extension ------

# See https://imagej.net/scripting/headless to deal with the mess of single quotes vs double quotes

echo "--- Installing BIOP extension"
argQuPathExtensionURL="quPathExtensionURL=\"$biop_extension_url\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathExtensionURL,$argQuitAfterInstall"
"$fiji_path" --ij2 --run InstallQuPathExtension.groovy "$all_args"

echo "--- Installing Cellpose extension"
argQuPathExtensionURL="quPathExtensionURL=\"$cellpose_extension_url\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathExtensionURL,$argQuitAfterInstall"
"$fiji_path" --ij2 --run InstallQuPathExtension.groovy "$all_args"

echo "--- Installing Warpy extension"

argQuPathExtensionURL="quPathExtensionURL=\"$warpy_extension_url\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathExtensionURL,$argQuitAfterInstall"
"$fiji_path" --ij2 --run InstallQuPathExtension.groovy "$all_args"

echo "--- Installing ABBA extension"

argQuPathExtensionURL="quPathExtensionURL=\"$abba_extension_url\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathExtensionURL,$argQuitAfterInstall"
echo "$all_args"
"$fiji_path" --ij2 --run InstallQuPathExtension.groovy "$all_args"

echo "--- Installing Stardist extension"

argQuPathExtensionURL="quPathExtensionURL=\"$stardist_extension_url\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathExtensionURL,$argQuitAfterInstall"
echo "$all_args"
"$fiji_path" --ij2 --run InstallQuPathExtension.groovy "$all_args"

echo "--- Installing Stardist extension"

argQuPathExtensionURL="quPathExtensionURL=\"$biop_omero_extension_url\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathExtensionURL,$argQuitAfterInstall"
echo "$all_args"
"$fiji_path" --ij2 --run InstallQuPathExtension.groovy "$all_args"

echo -------- INSTALLATION OF OMERO DEPENDENCIES ---------

biop_omero_dependencies_url="https://github.com/ome/openmicroscopy/releases/download/v5.6.6/OMERO.java-5.6.6-ice36.zip"

argQuPathExtensionURL="quPathExtensionURL=\"$biop_omero_dependencies_url\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathExtensionURL,$argQuitAfterInstall"
echo "$all_args"
"$fiji_path" --ij2 --run InstallQuPathExtension.groovy "$all_args"

echo -------- INSTALLATION OF QUPATH BIOP SHARED SCRIPTS ---------

biop_qupath_scripts_url="https://github.com/BIOP/qupath-scripts/archive/refs/heads/main.zip"

argQuPathScriptsURL="quPathScriptsURL=\"$biop_qupath_scripts_url\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathScriptsURL,$argQuitAfterInstall"
echo "$all_args"
"$fiji_path" --ij2 --run InstallQuPathScripts.groovy "$all_args"

echo ------ INSTALLATION DONE ------
