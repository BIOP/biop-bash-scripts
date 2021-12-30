#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
function Help()
{
   # Display Help
   echo ------ Aligning Big Brains And Altlases Installer Script -------------
   echo "This batch file downloads and install ABBA components on your computer."
   echo "Aligning Big Brains and Atlases (ABBA for short) needs Fiji, QuPath "
   echo "and elastix, and a set of custom plugins."
   echo
   echo "You can specify the folder where to install these components as an "
   echo "argument of this script. For instance: "
   echo ""
   echo "Windows:"
   echo "./install_abba.sh \"C:/\""
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
abba_extension_version=0.1.1
elastix_version=5.0.1

qupath_abba_extension_url="https://github.com/BIOP/qupath-extension-abba/releases/download/${abba_extension_version}/qupath-extension-abba-${abba_extension_version}.zip"

# ----------------- MAIN --------------------------

echo ------ Aligning Big Brains And Altlases Installer Script -------------
echo "This batch file downloads and install ABBA components on your computer"
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
echo "- Latest ImageJ/Fiji"
echo -e " \t - Update Fiji"
echo -e " \t - Enable ABBA Update Site"
echo "- QuPath version: $qupath_version"
echo "- Elastix version: $elastix_version"
echo "- ABBA QuPath Extension: $abba_extension_version"

# ------- INSTALLATION PATH VALIDATION

echo ------- Installation path validation

if [ $# -eq 0 ] 
then
	echo "Please enter the installation path for ABBA's components"
	getuserdir path_install
else 	
	if [ -d "$1" ] ; then
		path_install=$1
	else
		echo $1 is not a valid path
		echo "Please enter the installation path for ABBA's components"
		getuserdir path_install
	fi	
fi

echo "All components will be installed in:"
echo "$path_install"

# MAKE TEMP FOLDER IN CASE DOWNLOADS ARE NECESSARY
temp_dl_dir="$path_install/temp_dl"
mkdir "$temp_dl_dir"

# ------ SETTING UP IMAGEJ/FIJI
echo ------ Setting up ImageJ/Fiji ------

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	echo "Linux unsupported - please contribute to this installer to support it!"
	pause "Press [Enter] to end the script"
	exit 1 # We cannot proceed
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Mac OSX unsupported - please contribute to this installer to support it!"
	pause "Press [Enter] to end the script"
	exit 1 # We cannot proceed
elif [[ "$OSTYPE" == "msys" ]]; then
	fiji_os_subpath="fiji-win64"
	fiji_executable_file="ImageJ-win64.exe"
	fiji_url="https://downloads.imagej.net/fiji/latest/fiji-win64.zip"
fi

fiji_path="$path_install/$fiji_os_subpath/Fiji.app/$fiji_executable_file"

echo "Looking for Fiji executable: $fiji_path"
if [[ -f "$fiji_path" ]]; then
    echo "Fiji detected, bypassing installation"
else
	echo "Fiji not present, downloading it"
	fiji_zip_path="$temp_dl_dir/fiji.zip"
	curl "$fiji_url" -# -o "$fiji_zip_path"
	echo "Unzipping Fiji in $path_install"
	unzip "$fiji_zip_path" -d "$path_install/$fiji_os_subpath"
fi

if [[ -f "$fiji_path" ]]; then
    echo "Fiji successfully installed."
else
	echo "Fiji installation failed, please retry with administrator rights or install in a folder requiring less priviledge"
	pause "Press [Enter] to end the script"
	exit 1 # We cannot proceed
fi

# Updating several times because there may be some issues with removing some files after a single update is performed
echo "Updating Fiji"
"$fiji_path" --update update
echo "Fiji updated"

echo "Enabling ABBA update site"
"$fiji_path" --update add-update-site "ABBA" "https://biop.epfl.ch/Fiji-ABBA-Exp/"
echo "ABBA update site enabled"

echo "Updating Fiji"
"$fiji_path" --update update
echo "Fiji updated"

echo "Updating Fiji one last time" 
"$fiji_path" --update update
echo "Fiji is now up-to-date"

echo "Setting up default ABBA atlases folder"

mkdir -p "$path_install/abba_atlases"

echo -n "$path_install/abba_atlases">"$path_install/$fiji_os_subpath/Fiji.app/plugins/BIOP/ABBA_Atlas_folder.txt"

# ------ SETTING UP ELASTIX ------
echo ------ Setting up Elastix ------

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	echo "Linux unsupported - please contribute to this installer to support it!"
	pause "Press [Enter] to end the script"
	exit 1 # We cannot proceed
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Mac OSX unsupported - please contribute to this installer to support it!"
	pause "Press [Enter] to end the script"
	exit 1 # We cannot proceed
elif [[ "$OSTYPE" == "msys" ]]; then
	elastix_os_subpath="elastix-$elastix_version-win64"
	elastix_executable_file="elastix.exe"
	transformix_executable_file="transformix.exe"
	elastix_url="https://github.com/SuperElastix/elastix/releases/download/${elastix_version}/elastix-${elastix_version}-win64.zip"
	
	echo "-- Windows specific: checking whether Visual Studio redistributable is installed"
	
	# Does the registry key exist?
	MSYS_NO_PATHCONV=1 reg query "HKLM\\SOFTWARE\\Microsoft\\VisualStudio\\14.0\\VC\\Runtimes\\x64" /v Major >dummy
	errorlevel=$?

	if [[ "$errorlevel" == "0" ]]; then
	    echo "VS Redistributable is installed."
	else 
	    echo "VS Redistributable is not installed - downloading it"
	    vc_redist_url="https://aka.ms/vs/16/release/vc_redist.x64.exe"
	    vc_redist_path="$temp_dl_dir/vc_redist_install.exe"
	    curl "$vc_redist_url" -L -# -o "$vc_redist_path"
	    echo "Launching VC redist install - Do not restart your computer at the end of the install"
	    "$vc_redist_path"
	    # Does the registry key exist NOW ?
	    MSYS_NO_PATHCONV=1 reg query "HKLM\\SOFTWARE\\Microsoft\\VisualStudio\\14.0\\VC\\Runtimes\\x64" /v Major >dummy
		errorlevel=$?
		if [[ "$errorlevel" == "0" ]]; then
		  echo "VS Redistributable is now installed."
		else 
		  echo "Something went wrong during VS redistributable installation!"
		  pause "Press [Enter] to end the script"
		  exit 1 # We cannot proceed	  
		fi
	fi
fi

elastix_path="$path_install/$elastix_os_subpath/$elastix_executable_file"
transformix_path="$path_install/$elastix_os_subpath/$transformix_executable_file"

if [[ -f "$elastix_path" ]]; then
    echo "Elastix detected, bypassing installation"
else
	echo "Elastix not present, downloading it from $elastix_url"
	elastix_zip_path="$temp_dl_dir/elastix.zip"
	curl "$elastix_url" -L -# -o "$elastix_zip_path"
	echo "Unzipping Elastix in $path_install"
	unzip "$elastix_zip_path" -d "$path_install"
fi

if [[ -f "$elastix_path" ]]; then
    echo "Elastix successfully installed."
else
	echo "Elastix installation failed, please retry with administrator rights or install in a folder requiring less priviledge"
	pause "Press [Enter] to end the script"
	exit 1 # We cannot proceed
fi

echo --- Setting Elastix and Transformix path in Fiji
argElastixPath="elastixPath=\"$elastix_path\""
argTransformixPath="transformixPath=\"$transformix_path\""
all_args="$argElastixPath,$argTransformixPath"
"$fiji_path" --ij2 --run SetElastixPath.groovy "$all_args"

# ------ SETTING UP QUPATH ------
echo ------ Setting up QuPath ------

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	echo "Linux unsupported - please contribute to this installer to support it!"
	pause "Press [Enter] to end the script"
	exit 1 # We cannot proceed
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Mac OSX unsupported - please contribute to this installer to support it!"
	pause "Press [Enter] to end the script"
	exit 1 # We cannot proceed
elif [[ "$OSTYPE" == "msys" ]]; then
	qupath_executable_file="QuPath-${qupath_version}.exe"
	qupath_url="https://github.com/qupath/qupath/releases/download/v${qupath_version}/QuPath-${qupath_version}-Windows.zip"
	qupath_path="$path_install/QuPath-${qupath_version}/$qupath_executable_file"
	if [[ -f "$qupath_path" ]]; then
		echo "QuPath detected, bypassing installation"
	else
		echo "QuPath not present, downloading it from $qupath_url"
		qupath_zip_path="$temp_dl_dir/qupath.zip"
		curl "$qupath_url" -L -# -o "$qupath_zip_path"
		echo "Unzipping QuPath"
		unzip "$qupath_zip_path" -d "$path_install"
		if [[ -f "$qupath_path" ]]; then
			echo "QuPath successfully installed"
		else
			echo "QuPath installation failed, please retry with administrator rights or install in a folder requiring less priviledge"
			pause "Press [Enter] to end the script"
			exit 1 # We cannot proceed
		fi
	fi	
fi

echo ------ Setting up QuPath extension ------

# See https://imagej.net/scripting/headless to deal with the mess of single quotes vs double quotes
argQuPathUserPath="defaultQuPathUserPath=\"$path_install/QuPath Common Data\""
argQuPathPrefNode="quPathPrefsNode=\"io.github.qupath/0.3\""
argQuPathExtensionURL="quPathExtensionURL=\"$qupath_abba_extension_url\""
argQuitAfterInstall="quitAfterInstall=\"true\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathExtensionURL,$argQuitAfterInstall"
"$fiji_path" --ij2 --run InstallQuPathExtension.groovy "$all_args"

# echo ------ Downloading Allen Brain Atlas ------
# allen_brain_mouse_ccfv3_h5_url="https://zenodo.org/record/4486659/files/ccf2017-mod65000-border-centered-mm-bc.h5"
# allen_brain_mouse_ccfv3_xml_url="https://zenodo.org/record/4486659/files/ccf2017-mod65000-border-centered-mm-bc.xml"

echo "Removing temporary download folder $temp_dl_dir"
rm -r "$temp_dl_dir"

echo ------ INSTALLATION DONE ------
echo "You should be able to run either Fiji or QuPath and access ABBA's functionalities"
echo "If this script failed, please post the errors in forum.image.sc with the ABBA tag"
pause 'Press [Enter] to end the script'