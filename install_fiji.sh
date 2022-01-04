#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
function Help()
{
   # Display Help
   echo ------ Fiji Installer Script -------------
   echo "This batch file downloads and install Fiji on your computer."
   echo "Fiji is automatically updated after download "
   echo
   echo "You can specify the folder where to install Fiji as an "
   echo "argument of this script. For instance: "
   echo ""
   echo "Windows:"
   echo "./install_fiji.sh C:/"
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

echo ------ ImageJ/Fiji Installer Script -------------
echo "This batch file downloads and install Fiji on your computer"
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


# ------- INSTALLATION PATH VALIDATION

echo ------- Installation path validation

if [ $# -eq 0 ] 
then
	echo "Please enter the installation path for Fiji"
	getuserdir path_install
else 	
	if [ -d "$1" ] ; then
		path_install=$1
	else
		echo $1 is not a valid path
		echo "Please enter the installation path for Fiji"
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

echo "Updating Fiji one last time" 
"$fiji_path" --update update
echo "Fiji should now be up-to-date"

echo "Removing temporary download folder $temp_dl_dir"
rm -r "$temp_dl_dir"
