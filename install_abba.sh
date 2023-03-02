#!/bin/bash
scriptpath= dirname $0

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
   echo 
   echo "Mac:"
   echo "./install_abba.sh /Applications/"
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
# qupath_version=0.4.3
# abba_extension_version=0.1.4
# elastix_version=5.0.1
source "$scriptpath/version_software_script.sh"
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
echo -e " \t - Enable PTBIOP Update Site"
echo "- QuPath version: $qupath_version"
echo "- Elastix version: $elastix_version"
echo "- ABBA QuPath Extension: $abba_extension_version"

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

# MAKE TEMP FOLDER IN CASE DOWNLOADS ARE NECESSARY
temp_dl_dir="$path_install/temp_dl"
mkdir "$temp_dl_dir"

# ------ SETTING UP IMAGEJ/FIJI
echo ------ Setting up ImageJ/Fiji ------
$scriptpath/install_fiji.sh "$path_install"
fiji_path="$path_install/Fiji.app/$fiji_executable_file"
echo "Enabling PTBIOP update site"
"$fiji_path" --update add-update-site "PTBIOP" "https://biop.epfl.ch/Fiji-Update/"
echo "PTBIOP update site enabled"

echo "Updating Fiji"
"$fiji_path" --update update
echo "Fiji updated"

echo "Updating Fiji one last time" 
"$fiji_path" --update update
echo "Fiji is now up-to-date"

echo "Setting up default ABBA atlases folder"

# ------ SETTING UP abba_atlases
mkdir -p "$path_install/abba_atlases"
mkdir -p "$path_install/Fiji.app/plugins/BIOP"

echo -n "$path_install/abba_atlases">"$path_install/Fiji.app/plugins/BIOP/ABBA_Atlas_folder.txt"

if [[ "$OSTYPE" == "darwin"* ]]; then
	echo "Your OS: Mac OSX, make the folder not read only"
	chflags -R nouchg "$path_install/Fiji.app"
	xattr -rd com.apple.quarantine "$path_install/Fiji.app"
	chmod -R a+w "$path_install/Fiji.app"
fi

# ------ SETTING UP ELASTIX ------
echo ------ Setting up Elastix ------

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	echo "Linux beta supported - please contribute to this installer to support it!"
	# pause "Press [Enter] to end the script"
	# exit 1 # We cannot proceed
	elastix_os_subpath="elastix-$elastix_version-linux"
	elastix_executable_file="bin/elastix"
	transformix_executable_file="bin/transformix"
	elastix_url="https://github.com/SuperElastix/elastix/releases/download/${elastix_version}/elastix-${elastix_version}-linux.zip"
elif [[ "$OSTYPE" == "darwin"* ]]; then
	elastix_os_subpath="elastix-$elastix_version-mac"
	elastix_executable_file="bin/elastix"
	transformix_executable_file="bin/transformix"
	elastix_url="https://github.com/SuperElastix/elastix/releases/download/${elastix_version}/elastix-${elastix_version}-mac.zip"
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
	echo "Elastix installation failed, please retry with administrator rights or install in a folder requiring less privilege"
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
$scriptpath/install_qupath.sh "$path_install"

echo ------ Setting up QuPath extension ------
#TODO refine here verify if QPath is in directory define a QuPath dir where the version is not precised
# See https://imagej.net/scripting/headless to deal with the mess of single quotes vs double quotes

all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathExtensionURL,$argQuitAfterInstall"
"$fiji_path" --ij2 --run InstallQuPathExtension.groovy "$all_args"

echo "Removing temporary download folder $temp_dl_dir"
rm -r "$temp_dl_dir"

if [[ "$OSTYPE" == "darwin"* ]]; then
	echo "Your OS: Mac OSX, make the qupath extension folder not read only"
	chmod -R a+w "$path_install/QuPath Common Data_0.4"
fi

echo ------ INSTALLATION DONE ------
echo "You should be able to run either Fiji or QuPath and access ABBA's functionalities"
echo "If this script failed, please post the errors in forum.image.sc with the ABBA tag"
