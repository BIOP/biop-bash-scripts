#!/bin/bash
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    scriptpath=$(realpath $(dirname $0))
elif [[ "$OSTYPE" == "darwin"* ]]; then
    scriptpath=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
elif [[ "$OSTYPE" == "msys" ]]; then
    scriptpath=$(realpath $(dirname $0))
fi
source "$scriptpath/global_function.sh"

################################################################################
# Help                                                                         #
################################################################################
function Help()
{
   # Display Help
   echo ------ Fiji Installer Script -------------
   echo "This script file downloads and installs Fiji on your computer."
   echo "Fiji is automatically updated after download "
   echo
   echo "You can specify the folder where to install Fiji as an "
   echo "argument of this script. For instance: "
   echo ""
   echo "Windows:"
   echo "./install_fiji.sh C:/"
   echo ""
   echo "Mac:"
   echo "./install_fiji.sh /Applications/"
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

echo ------ ImageJ/Fiji Installer Script -------------
#  ------- INSTALLATION PATH VALIDATION and Check system if not already done
if [ $# -eq 0 ] 
then
	path_validation
else 	
	path_validation $1
fi

# MAKE TEMP FOLDER IN CASE DOWNLOADS ARE NECESSARY
temp_dl_dir="$path_install/temp_dl"
mkdir -p "$temp_dl_dir"


# ------ SETTING UP IMAGEJ/FIJI
echo ------ Setting up ImageJ/Fiji ------

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	echo "Linux beta supported - please contribute to this installer to support it!"
	fiji_executable_file="ImageJ-linux64"
	fiji_url="https://downloads.imagej.net/fiji/latest/fiji-linux64.zip"
	echo "[Desktop Entry]
Type=Application
Name=Fiji
Comment=QuPath
Icon=$path_install/Fiji.app/images/icon-flat.png
Exec="$path_install/Fiji.app/$fiji_executable_file"
Terminal=false  #ouvrir ou non un terminal lors de l'exécution du programme (false ou true)
StartupNotify=false  #notification de démarrage ou non (false ou true)
Categories=Analyse image  #Exemple: Categories=Application;;" > ~/.local/share/applications/Fiji.desktop
elif [[ "$OSTYPE" == "darwin"* ]]; then
	fiji_executable_file="Contents/MacOS/ImageJ-macosx"
	fiji_url="https://downloads.imagej.net/fiji/latest/fiji-macosx.zip"
elif [[ "$OSTYPE" == "msys" ]]; then
	fiji_executable_file="ImageJ-win64.exe"
	fiji_url="https://downloads.imagej.net/fiji/latest/fiji-win64.zip"
fi

fiji_path="$path_install/Fiji.app/$fiji_executable_file"

echo "Looking for Fiji executable: $fiji_path"
if [[ -f "$fiji_path" ]]; then
    echo "Fiji detected, bypassing installation"
else
	echo "Fiji not present, downloading it"
	fiji_zip_path="$temp_dl_dir/fiji.zip"
	curl "$fiji_url" -# -o "$fiji_zip_path"
	echo "Unzipping Fiji in $path_install"
	unzip "$fiji_zip_path" -d "$path_install/"
	if [[ "$OSTYPE" == "darwin"* ]]; then
		echo "Your OS: Mac OSX, make the folder not read only"
		chflags -R nouchg "$path_install/Fiji.app"
		xattr -rd com.apple.quarantine "$path_install/Fiji.app"
		chmod -R a+w "$path_install/Fiji.app"
	fi
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

if [[ "$OSTYPE" == "darwin"* ]]; then
	echo "Your OS: Mac OSX, make the folder not read only"
	chflags -R nouchg "$path_install/Fiji.app"
	xattr -rd com.apple.quarantine "$path_install/Fiji.app"
	chmod -R a+w "$path_install/Fiji.app"
fi

echo "Updating Fiji one last time" 
"$fiji_path" --update update
echo "Fiji should now be up-to-date"

if [[ "$OSTYPE" == "darwin"* ]]; then
	echo "Your OS: Mac OSX, make the folder not read only"
	chflags -R nouchg "$path_install/Fiji.app"
	xattr -rd com.apple.quarantine "$path_install/Fiji.app"
	chmod -R a+w "$path_install/Fiji.app"
fi

echo "Removing temporary download folder $temp_dl_dir"
rm -r "$temp_dl_dir"
