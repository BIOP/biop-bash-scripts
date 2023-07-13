#!/bin/bash
scriptpath=$(realpath $(dirname $0))
source "$scriptpath/global_function.sh"

################################################################################
# Help                                                                         #
################################################################################
function Help()
{
   # Display Help
   echo ------ ABBA Full Installer -------------
   echo "This script executes sequentially:"
   echo "    - install_abba.sh"
   echo "    - install_abba_atlases.sh"
   echo
   echo "You need to specify the folder where ABBA components should be installed as an "
   echo "argument of this script. For instance: "
   echo ""
   echo "Windows:"
   echo "./full_install_abba.sh \"C:/\""
   echo 
   echo "Mac:"
   echo "./full_install_abba.sh /Applications/"
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


echo ------ ImageJ/Fiji BIOP Full Installer Script -------------
#  ------- INSTALLATION PATH VALIDATION and Check system if not already done
if [ $# -eq 0 ] 
then
	path_validation
else 	
	path_validation $1
fi

scriptname=$(realpath $(dirname $0))
. "$scriptname/install_abba.sh" "$path_install"
. "$scriptname/install_abba_atlases.sh" "$path_install"
