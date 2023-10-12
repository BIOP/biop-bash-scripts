#!/bin/bash
if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "msys" ]]; then
    scriptpath=$(realpath $(dirname $0))
elif [[ "$OSTYPE" == "darwin"* ]]; then
    scriptpath=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
fi
source "$scriptpath/global_function.sh"

################################################################################
# Help                                                                         #
################################################################################
function Help()
{
   # Display Help
   echo ------ Aligning Big Brains And Altlases Atlases Installer Script -------------
   echo "If you have run the install abba script, this script will "
   echo "download the mouse allen brain atlas and rat atlas into the"
   echo "the appropriate default atlas folder (/abba_atlases)."
   echo "If atlases have already been downloaded, nothing will happen."
   echo
   echo "You can specify the folder where to install these components as an "
   echo "argument of this script. For instance: "
   echo ""
   echo "Windows:"
   echo "./install_abba_atlases.sh \"C:/\""
   echo 
   echo "Mac:"
   echo "./install_abba_atlases.sh /Applications/"
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


#
# ----------------- MAIN --------------------------

echo ------ Aligning Big Brains And Altlases Installer Script -------------

#  ------- INSTALLATION PATH VALIDATION and Check system if not already done
if [ $# -eq 0 ] 
then
	path_validation
else 	
	path_validation $1
fi

# ------ SETTING UP IMAGEJ/FIJI

echo "Creating ABBA atlases folder, if it does not exist"

mkdir -p "$path_install/abba_atlases"

echo "--- Downloading Mouse Adult Allen Brain Atlas CCFv3.1 (https://zenodo.org/record/7492551)"
echo "- Ontology"
ontology_path="$path_install/abba_atlases/1.json"
if test -f "$ontology_path"; then
    echo "$ontology_path already exists - skipping"
else
	curl "https://zenodo.org/record/7492551/files/1.json" -L -# -o "$ontology_path"  
fi
echo "- Xml"
xml_path="$path_install/abba_atlases/mouse_brain_ccfv3.xml"
if test -f "$xml_path"; then
    echo "$xml_path already exists - skipping"
else
	curl "https://zenodo.org/record/7492551/files/ccf2017-mod65000-border-centered-mm-bc.xml" -L -# -o "$xml_path"
fi
echo "- Hdf5"
h5_path="$path_install/abba_atlases/ccf2017-mod65000-border-centered-mm-bc.h5"
if test -f "$h5_path"; then
    echo "$h5_path already exists - skipping"
else
	curl "https://zenodo.org/record/7492551/files/ccf2017-mod65000-border-centered-mm-bc.h5" -L -# -o "$h5_path"
fi

echo "--- Downloading Waxholm Space atlas of the Sprague Dawley Rat Brain V4.2 (https://zenodo.org/record/8092060)"
echo "- Ontology"
ontology_path="$path_install/abba_atlases/WHS_SD_rat_atlas_v4_labels.ilf"
if test -f "$ontology_path"; then
    echo "$ontology_path already exists - skipping"
else
	curl "https://zenodo.org/record/8092060/files/WHS_SD_rat_atlas_v4_labels.ilf" -L -# -o "$ontology_path"
fi
echo "- Xml"
xml_path="$path_install/abba_atlases/WHS_SD_rat_atlas_v4.xml"
if test -f "$xml_path"; then
    echo "$xml_path already exists - skipping"
else
	curl "https://zenodo.org/record/8092060/files/WHS_SD_rat_atlas_v4p2.xml" -L -# -o "$xml_path"
fi
echo "- Hdf5"
h5_path="$path_install/abba_atlases/WHS_SD_rat_atlas_v4.h5"
if test -f "$h5_path"; then
    echo "$h5_path already exists - skipping"
else
	curl "https://zenodo.org/record/8092060/files/WHS_SD_rat_atlas_v4p1.h5" -L -# -o "$h5_path"
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
	echo "Your OS: Mac OSX, make the folder not read only"
	chflags -R nouchg "$path_install/abba_atlases"
	xattr -rd com.apple.quarantine "$path_install/abba_atlases"
	chmod -R a+w "$path_install/abba_atlases"
fi

echo ------ DONE ------
