#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
function Help()
{
   # Display Help
   echo ------ Fiji Update Sites Installer Script -------------
   echo "This adds update sites to an existing Fiji install"
   echo "The following sites are automatically installed:"
   echo "    - 3D Image Suite"   
   echo "    - ABBA"
   echo "    - Bio-Formats"
   echo "    - CSBDeep"
   echo "    - Fiji-EasyXT"
   echo "    - IBMP-CNRS"
   echo "    - IJPB-Plugins"
   echo "    - ImageScience"
   echo "    - Operetta Importer"
   echo "    - PTBIOP (obviously)"
   echo "    - Stardist"
   echo "    - TensorFlow"
   echo
   echo "You need to specify the folder where Fiji is installed as an "
   echo "argument of this script. For instance: "
   echo ""
   echo "Windows:"
   echo "./install_fiji_update_sites.sh C:/"
   echo 
   echo "Mac:"
   echo "./install_fiji_update_sites.sh /Applications/"
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
echo "This batch file installs a selection of Fiji update sites"
echo "Make sure Fiji is closed while running this script!"
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
    echo "Fiji is present"
else
	echo "Fiji not present, exiting script"
	exit 1 # We cannot proceed
fi

# Updating several times because there may be some issues with removing some files after a single update is performed
echo "Updating Fiji"
"$fiji_path" --update update
echo "Fiji updated"

echo "3D ImageJ Suite"
"$fiji_path" --update add-update-site "3D ImageJ Suite" "https://sites.imagej.net/Tboudier/"

# echo "Enabling BigStitcher update site"
# "$fiji_path" --update add-update-site "BigStitcher" "https://sites.imagej.net/BigStitcher/"

echo "Enabling Bio-Formats update site"
"$fiji_path" --update add-update-site "Bio-Formats" "https://sites.imagej.net/Bio-Formats/"

echo "Enabling CSBDeep update site"
"$fiji_path" --update add-update-site "CSBDeep" "https://sites.imagej.net/CSBDeep/"

echo "Enabling Fiji-EasyXT update site"
"$fiji_path" --update add-update-site "Fiji-EasyXT" "https://biop.epfl.ch/Fiji-EasyXT/"

echo "Enabling IBMP-CNRS update site"
"$fiji_path" --update add-update-site "IBMP-CNRS" "https://sites.imagej.net/Mutterer/"

echo "Enabling IJPB-plugins update site"
"$fiji_path" --update add-update-site "IJPB-plugins" "https://sites.imagej.net/IJPB-plugins/"

echo "Enabling ImageScience update site"
"$fiji_path" --update add-update-site "ImageScience" "https://sites.imagej.net/ImageScience/"

echo "Enabling PTBIOP update site"
"$fiji_path" --update add-update-site "PTBIOP" "https://biop.epfl.ch/Fiji-Update"

echo "Enabling StarDist update site"
"$fiji_path" --update add-update-site "StarDist" "https://sites.imagej.net/StarDist/"

echo "Enabling TensorFlow update site"
"$fiji_path" --update add-update-site "TensorFlow" "https://sites.imagej.net/TensorFlow/"

echo "Updating Fiji again" 
"$fiji_path" --update update
echo "Fiji should now be up-to-date"

echo "Updating Fiji one last time" 
"$fiji_path" --update update
echo "Fiji should now be up-to-date"
