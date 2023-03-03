#!/bin/bash
scriptpath=$(realpath $(dirname $0))
source "$scriptpath/version_software_script.sh" # Versions need to be sourced before global function!
source "$scriptpath/global_function.sh"

################################################################################
# Help                                                                         #
################################################################################
function Help()
{
   # Display Help
   echo ------ BIOP QuPath Full Installer -------------
   echo "This script executes sequentially:"
   echo "    - install_qupath.sh"
   echo "    - install_qupath_extensions.sh"
   echo
   echo "You need to specify the folder where Qupath should be installed as an "
   echo "argument of this script. For instance: "
   echo "Fiji needs to be already installed in the same path"
   echo ""
   echo "Windows:"
   echo "./full_install_biop_qupath.sh C:/"
   echo 
   echo "Mac:"
   echo "./full_install_biop_qupath.sh /Applications/"
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

echo ------ QuPath BIOP Full Installer Script -------------
echo "This batch file downloads and install QuPath + extensions on your computer"
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
    echo "Please enter the installation path (windows: C:/, mac: /Applications/, Linux : /home/user/abba)"
	echo "The directory must exist first."
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

. "$scriptpath/install_qupath.sh" "$path_install"
. "$scriptpath/install_qupath_extensions.sh" "$path_install"
