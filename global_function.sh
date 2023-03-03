# ----------------- FUNCTIONS -------------------

# Wait for user 
function pause(){
   read -p "$*"
}

# Returns get path from user
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

#Check if the script is run independently.
#TODO one day replace all dir install check by a function

#Check the system :
function system_check(){
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
}

#function checkdir
function path_validation(){
	if [ $# -eq 0 ] 
	then
		echo ------- Installation path validation
		system_check
		echo "Please enter the installation path (windows: C:/, mac: /Applications/)"
		getuserdir path_install
	else 	
		if [ -d "$1" ] ; then
			path_install=$1
		else
			echo $1 is not a valid path
			echo "Please enter the installation path for QuPath"
			getuserdir path_install
		fi	
	fi
	echo "All components will be installed in:"
	echo "$path_install"
}