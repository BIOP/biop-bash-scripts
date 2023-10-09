#!/bin/bash
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    scriptpath=$(realpath $(dirname $0))
elif [[ "$OSTYPE" == "darwin"* ]]; then
    scriptpath=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
elif [[ "$OSTYPE" == "msys" ]]; then
    scriptpath=$(realpath $(dirname $0))
fi
source "$scriptpath/version_software_script.sh" # Versions need to be sourced before global function!
source "$scriptpath/global_function.sh"

################################################################################
# Help                                                                         #
################################################################################
function Help()
{
   # Display Help
   echo ------ QuPath Installer Script -------------
   echo "This batch file downloads and install QuPath-v$qupath_version on your computer."
   echo
   echo "You can specify the folder where to install QuPath as an "
   echo "argument of this script. For instance: "
   echo ""
   echo "Windows:"
   echo "./install_qupath.sh C:/"
   echo 
   echo "Mac:"
   echo "./install_qupath.sh /Applications/"
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

echo ------ QuPath Installer Script -------------
#  ------- INSTALLATION PATH VALIDATION and Check system if not already done
if [ $# -eq 0 ] 
then
	path_validation
else 	
	path_validation $1
fi

# MAKE TEMP FOLDER IN CASE DOWNLOADS ARE NECESSARY
temp_dl_dir="$path_install/temp_dl"
mkdir "$temp_dl_dir"

# ------ SETTING UP QUPATH ------
echo ------ Setting up QuPath ------


if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	echo "Linux beta supported - please contribute to this installer to support it!"
	qupath_executable_file="QuPath"
	qupath_url="https://github.com/qupath/qupath/releases/download/v${qupath_version}/QuPath-${qupath_version}-Linux.tar.xz"
	qupath_path="$path_install/QuPath/bin/$qupath_executable_file"
	if [[ -f "$qupath_path" ]]; then
		echo "QuPath detected, bypassing installation"
	else
		echo "QuPath not present, downloading it from $qupath_url"
		qupath_zip_path="$temp_dl_dir/QuPath-${qupath_version}-Linux.tar.xz"
		curl "$qupath_url" -L -# -o "$qupath_zip_path"
		echo "Unzipping QuPath"
		tar -f "$qupath_zip_path" -C "$path_install/" -xv
		echo "We give execution right"
		chmod u+x "$path_install/QuPath/bin/QuPath"
		chmod u+x "$path_install/QuPath/bin/QuPath.sh"
		echo "[Desktop Entry]
Type=Application
Name=QuPath
Comment=QuPath
Icon=$path_install/QuPath/lib/QuPath.png
Exec=$qupath_path.sh
Terminal=false  #ouvrir ou non un terminal lors de l'exécution du programme (false ou true)
StartupNotify=false  #notification de démarrage ou non (false ou true)
Categories=Analyse image  #Exemple: Categories=Application;;" > ~/.local/share/applications/QuPath.desktop
		if [[ -f "$qupath_path" ]]; then
			echo "QuPath successfully installed"
		else
			echo "QuPath installation failed, please retry with administrator rights or install in a folder requiring less priviledge"
			pause "Press [Enter] to end the script"
			exit 1 # We cannot proceed
		fi
	fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
	qupath_executable_file="Contents/MacOS/QuPath"
	qupath_path="/Applications/QuPath.app/$qupath_executable_file"
	echo "$qupath_path"
	if [[ -f "$qupath_path" ]]; then
		echo "QuPath detected, bypassing installation"
	else
		qupath_url="https://github.com/qupath/qupath/releases/download/v${qupath_version}/QuPath-${qupath_version}-Mac.pkg"
		echo "QuPath not present, downloading it from $qupath_url"
		qupath_zip_path="$temp_dl_dir/qupath.pkg"
		curl "$qupath_url" -L -# -o "$qupath_zip_path"
		echo "Installing QuPath, you will need to enter your admin password for the install (or install QuPath before running the script)"
		sudo installer -pkg "$qupath_zip_path" -target /
		if [[ -f "$qupath_path" ]]; then
			echo "QuPath successfully installed"
		else
			echo "QuPath installation failed, please retry with administrator rights or install in a folder requiring less privilege"
			pause "Press [Enter] to end the script"
			exit 1 # We cannot proceed
		fi
	fi
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


echo "Removing temporary download folder $temp_dl_dir"
rm -r "$temp_dl_dir"
