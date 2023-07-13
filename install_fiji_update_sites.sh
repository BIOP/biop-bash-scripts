#!/bin/bash
scriptpath=$(realpath $(dirname $0))
source "$scriptpath/global_function.sh"

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
   echo "    - Bio-Formats"
   echo "    - CSBDeep"
   echo "    - IBMP-CNRS"
   echo "    - IJPB-Plugins"
   echo "    - ImageScience"
   echo "    - OMERO 5.5-5.6"
   echo "    - PTBIOP"
   echo "    - ilastik"
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


echo ------ ImageJ/Fiji Installer Script -------------
echo "This batch file installs a selection of Fiji update sites"
echo "Make sure Fiji is closed while running this script!"

#  ------- INSTALLATION PATH VALIDATION and Check system if not already done
if [ $# -eq 0 ] 
then
	path_validation
else 	
	path_validation $1
fi

# ------ SETTING UP IMAGEJ/FIJI
echo ------ Setting up ImageJ/Fiji ------

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

# if "$fiji_path" --update update ; then 
#    echo "Fiji updated"
# else
#    echo "Error in Fiji update"
# fi

#Replace following lines by :
# echo "Enabling all update sites"
# $fiji_path --update add-update-sites \
# 	"PTBIOP" "https://biop.epfl.ch/Fiji-Update"\
# 	"OMERO 5.5-5.6" "https://sites.imagej.net/OMERO-5.5-5.6/"\
# 	"StarDist" "https://sites.imagej.net/StarDist/"\

# echo "Updating Fiji"
# "$fiji_path" --update update
# echo "Fiji updated"   
sleep 20

# We need pauses between each update
# https://forum.image.sc/t/repeated-imagej-updater-calls-cause-403-errors/76613 

echo "Enabling PTBIOP update site"
"$fiji_path" --update add-update-site "PTBIOP" "https://biop.epfl.ch/Fiji-Update"

sleep 40

echo "Enabling OMERO 5.5-5.6 update site"
"$fiji_path" --update add-update-site "OMERO 5.5-5.6" "https://sites.imagej.net/OMERO-5.5-5.6/"

sleep 40

echo "Enabling StarDist update site"
$fiji_path --update add-update-site "StarDist" "https://sites.imagej.net/StarDist/"

sleep 40

echo "Updating Fiji one last time" 
$fiji_path --update update
echo "Fiji should now be up-to-date"
