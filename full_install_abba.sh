#!/bin/bash

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

echo ------ ImageJ/Fiji BIOP Full Installer Script -------------
echo "This batch file downloads and install all components on your computer"
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

./install_abba.sh "$path_install"
./install_abba_atlases.sh "$path_install"
