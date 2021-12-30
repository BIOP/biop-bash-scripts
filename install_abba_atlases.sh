#!/bin/bash

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

# ----------------- MAIN --------------------------

echo ------ Aligning Big Brains And Altlases Installer Script -------------

# ------- INSTALLATION PATH VALIDATION

echo ------- Installation path validation

if [ $# -eq 0 ] 
then
	echo "Please enter the installation path for atlases, (without abba_atlases subfolder)"
	getuserdir path_install
else 	
	if [ -d "$1" ] ; then
		path_install=$1
	else
		echo $1 is not a valid path
		echo "Please enter the installation path for atlases, (without abba_atlases subfolder)"
		getuserdir path_install
	fi	
fi

# ------ SETTING UP IMAGEJ/FIJI

echo "Creating ABBA atlases folder, if it does not exist"

mkdir -p "$path_install/abba_atlases"

echo "--- Downloading Mouse Adult Allen Brain Atlas CCFv3 (https://zenodo.org/record/4486659#.Yc2Rklko_iE)"
echo "- Ontology"
ontology_path="$path_install/abba_atlases/1.json"
if test -f "$ontology_path"; then
    echo "$ontology_path already exists - skipping"
else
	curl "https://zenodo.org/record/4486659/files/1.json" -L -# -o "$ontology_path"
fi
echo "- Xml"
xml_path="$path_install/abba_atlases/mouse_brain_ccfv3.xml"
if test -f "$xml_path"; then
    echo "$xml_path already exists - skipping"
else
	curl "https://zenodo.org/record/4486659/files/ccf2017-mod65000-border-centered-mm-bc.xml" -L -# -o "$xml_path"
fi
echo "- Hdf5"
h5_path="$path_install/abba_atlases/ccf2017-mod65000-border-centered-mm-bc.h5"
if test -f "$h5_path"; then
    echo "$h5_path already exists - skipping"
else
	curl "https://zenodo.org/record/4486659/files/ccf2017-mod65000-border-centered-mm-bc.h5" -L -# -o "$h5_path"
fi

echo "--- Downloading Waxholm Space atlas of the Sprague Dawley Rat Brain V4 (https://zenodo.org/record/5644162#.Yc2Rq1ko_iE)"
echo "- Ontology"
ontology_path="$path_install/abba_atlases/WHS_SD_rat_atlas_v4_labels.ilf"
if test -f "$ontology_path"; then
    echo "$ontology_path already exists - skipping"
else
	curl "https://zenodo.org/record/5644162/files/WHS_SD_rat_atlas_v4_labels.ilf" -L -# -o "$ontology_path"
fi
echo "- Xml"
xml_path="$path_install/abba_atlases/WHS_SD_rat_atlas_v4.xml"
if test -f "$xml_path"; then
    echo "$xml_path already exists - skipping"
else
	curl "https://zenodo.org/record/5644162/files/WHS_SD_rat_atlas_v4.xml" -L -# -o "$xml_path"
fi
echo "- Hdf5"
h5_path="$path_install/abba_atlases/WHS_SD_rat_atlas_v4.h5"
if test -f "$h5_path"; then
    echo "$h5_path already exists - skipping"
else
	curl "https://zenodo.org/record/5644162/files/WHS_SD_rat_atlas_v4.h5" -L -# -o "$h5_path"
fi


echo ------ DONE ------