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
   echo ------ BIOP Fiji Full Installer -------------
   echo "This script executes sequentially:"
   echo "    - install_fiji.sh"
   echo "    - install_fiji_update_sites.sh"
   echo
   echo "You need to specify the folder where Fiji should be installed as an "
   echo "argument of this script. For instance: "
   echo ""
   echo "Windows:"
   echo "./full_install_biop_fiji.sh C:/"
   echo 
   echo "Mac:"
   echo "./full_install_biop_fiji.sh /Applications/"
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

. "$scriptpath/install_fiji.sh" "$path_install"
. "$scriptpath/install_fiji_update_sites.sh" "$path_install"
