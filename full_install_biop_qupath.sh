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

#  ------- INSTALLATION PATH VALIDATION and Check system if not already done
if [ $# -eq 0 ] 
then
	path_validation
else 	
	path_validation $1
fi

echo ------ QuPath BIOP Full Installer Script -------------
echo "This batch file downloads and install QuPath + extensions on your computer"

. "$scriptpath/install_qupath.sh" "$path_install"
. "$scriptpath/install_qupath_extensions.sh" "$path_install"
