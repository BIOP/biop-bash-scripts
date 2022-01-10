#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
function Help()
{
   # Display Help
   echo ------QuPath extensions installer Script -------------
   echo "This batch file downloads and install some biop selected QuPath (v0.3) extensions."
   echo 
   echo "  - https://github.com/BIOP/qupath-extension-biop"
   echo "  - https://github.com/BIOP/qupath-extension-cellpose"
   echo "  - https://github.com/BIOP/qupath-extension-warpy"
   echo "  - https://github.com/BIOP/qupath-extension-abba"
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
qupath_version=0.3.1

biop_extension_version=1.0.3
cellpose_extension_version=0.3.0
warpy_extension_version=0.2.0
abba_extension_version=0.1.1

biop_extension_url="https://github.com/BIOP/qupath-extension-biop/releases/download/v${biop_extension_version}/qupath-extension-biop-${biop_extension_version}.jar"

cellpose_extension_url="https://github.com/BIOP/qupath-extension-cellpose/releases/download/v${cellpose_extension_version}/qupath-extension-cellpose-${cellpose_extension_version}.jar"

warpy_extension_url="https://github.com/BIOP/qupath-extension-warpy/releases/download/${warpy_extension_version}/qupath-extension-warpy-${warpy_extension_version}.zip"

abba_extension_url="https://github.com/BIOP/qupath-extension-abba/releases/download/${abba_extension_version}/qupath-extension-abba-${abba_extension_version}.zip"

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

# ------- INSTALLATION PATH VALIDATION

echo ------- Installation path validation

if [ $# -eq 0 ] 
then
	echo "Please enter the installation path (windows: C:/, mac: /Applications/)"
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
	echo "Linux unsupported - please contribute to this installer to support it!"
	pause "Press [Enter] to end the script"
	exit 1 # We cannot proceed
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
	echo "Linux unsupported - please contribute to this installer to support it!"
	pause "Press [Enter] to end the script"
	exit 1 # We cannot proceed
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
argQuPathUserPath="defaultQuPathUserPath=\"$path_install/QuPath Common Data_0.3\""
argQuPathPrefNode="quPathPrefsNode=\"io.github.qupath/0.3\""
argQuitAfterInstall="quitAfterInstall=\"true\""

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

echo ------ INSTALLATION DONE ------
