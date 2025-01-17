#!/bin/bash
if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "msys" ]]; then
    scriptpath=$(realpath $(dirname $0))
elif [[ "$OSTYPE" == "darwin"* ]]; then
    scriptpath=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
fi

source "$scriptpath/global_function.sh"
source "$scriptpath/version_software_script.sh"

################################################################################
# Help                                                                         #
################################################################################
function Help()
{
   # Display Help
   echo ------ Warpy Installer Script -------------
   echo "This batch file downloads and install Warpy components on your computer."
   echo "Warpy needs Fiji, QuPath, elastix"
   echo "and associated plugins and extensions."
   echo
   echo "You can specify the folder where to install these components as an "
   echo "argument of this script. For instance: "
   echo ""
   echo "Windows:"
   echo "./install_warpy.sh \"C:/\""
   echo "" 
   echo "Mac OSX:"
   echo "./install_warpy.sh /Applications/"
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

# ----------------- COMPONENTS VERSION -----------
qupath_warpy_extension_url="https://github.com/BIOP/qupath-extension-warpy/releases/download/${warpy_extension_version}/qupath-extension-warpy-${warpy_extension_version}.zip"

# ----------------- MAIN --------------------------

echo ------ Warpy Installer Script -------------
echo "This batch file downloads and install Warpy components on your computer"
echo "See https://imagej.net/plugins/bdv/warpy/warpy"
#  ------- INSTALLATION PATH VALIDATION and Check system if not already done
if [ $# -eq 0 ] 
then
	path_validation
else 	
	path_validation $1
fi

echo "- Latest ImageJ/Fiji"
echo -e " \t - Update Fiji"
echo -e " \t - Enable Bigdataviewer-Playground Update Site"
echo "- QuPath version: $qupath_version"
echo "- Elastix version: $elastix_version"
echo "- Warpy QuPath Extension: $warpy_extension_version"

# MAKE TEMP FOLDER IN CASE DOWNLOADS ARE NECESSARY
temp_dl_dir="$path_install/temp_dl"
mkdir -p "$temp_dl_dir"

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
    echo "Fiji detected, bypassing installation"
else
	echo "Fiji not present, downloading it"
	fiji_zip_path="$temp_dl_dir/fiji.zip"
	curl "$fiji_url" -# -o "$fiji_zip_path"
	echo "Unzipping Fiji in $path_install"
	unzip "$fiji_zip_path" -d "$path_install/"
fi

if [[ -f "$fiji_path" ]]; then
    echo "Fiji successfully installed."
else
	echo "Fiji installation failed, please retry with administrator rights or install in a folder requiring less privilege"
	pause "Press [Enter] to end the script"
	exit 1 # We cannot proceed
fi

# Updating several times because there may be some issues with removing some files after a single update is performed
echo "Updating Fiji"
"$fiji_path" --update update
echo "Fiji updated"

echo "Enabling PTBIOP update site"
"$fiji_path" --update add-update-site "PTBIOP" "https://biop.epfl.ch/Fiji-Update/"
echo "PTBIOP update site enabled"

echo "Updating Fiji"
"$fiji_path" --update update
echo "Fiji updated"

echo "Updating Fiji one last time" 
"$fiji_path" --update update
echo "Fiji is now up-to-date"

# ------ SETTING UP ELASTIX ------
echo ------ Setting up Elastix ------

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	elastix_os_subpath="elastix-$elastix_version-linux"
	elastix_executable_file="bin/elastix"
	transformix_executable_file="bin/transformix"
	elastix_url="https://github.com/SuperElastix/elastix/releases/download/${elastix_version}/elastix-${elastix_version}-linux.zip"
elif [[ "$OSTYPE" == "darwin"* ]]; then
	elastix_os_subpath="elastix-$elastix_version-mac"
	elastix_executable_file="bin/elastix"
	transformix_executable_file="bin/transformix"
	elastix_url="https://github.com/SuperElastix/elastix/releases/download/${elastix_version}/elastix-${elastix_version}-mac.zip"
elif [[ "$OSTYPE" == "msys" ]]; then
	elastix_os_subpath="elastix-$elastix_version-win64"
	elastix_executable_file="elastix.exe"
	transformix_executable_file="transformix.exe"
	elastix_url="https://github.com/SuperElastix/elastix/releases/download/${elastix_version}/elastix-${elastix_version}-win64.zip"
	
	echo "-- Windows specific: checking whether Visual Studio redistributable is installed"
	
	# Does the registry key exist?
	MSYS_NO_PATHCONV=1 reg query "HKLM\\SOFTWARE\\Microsoft\\VisualStudio\\14.0\\VC\\Runtimes\\x64" /v Major >dummy
	errorlevel=$?

	if [[ "$errorlevel" == "0" ]]; then
	    echo "VS Redistributable is installed."
	else 
	    echo "VS Redistributable is not installed - downloading it"
	    vc_redist_url="https://aka.ms/vs/16/release/vc_redist.x64.exe"
	    vc_redist_path="$temp_dl_dir/vc_redist_install.exe"
	    curl "$vc_redist_url" -L -# -o "$vc_redist_path"
	    echo "Launching VC redist install - Do not restart your computer at the end of the install"
	    "$vc_redist_path"
	    # Does the registry key exist NOW ?
	    MSYS_NO_PATHCONV=1 reg query "HKLM\\SOFTWARE\\Microsoft\\VisualStudio\\14.0\\VC\\Runtimes\\x64" /v Major >dummy
		errorlevel=$?
		if [[ "$errorlevel" == "0" ]]; then
		    echo "VS Redistributable is now installed."
		else 
		    echo "Something went wrong during VS redistributable installation!"
		    pause "Press [Enter] to end the script"
		    exit 1 # We cannot proceed	  
		fi
	fi
fi

elastix_path="$path_install/$elastix_os_subpath/$elastix_executable_file"
transformix_path="$path_install/$elastix_os_subpath/$transformix_executable_file"

if [[ -f "$elastix_path" ]]; then
    echo "Elastix detected, bypassing installation"
else
	# MAKE TEMP FOLDER IN CASE DOWNLOADS ARE NECESSARY
	temp_dl_dir="$path_install/temp_dl"
	mkdir -p "$temp_dl_dir"
	echo "Elastix not present, downloading it from $elastix_url"
	elastix_zip_path="$temp_dl_dir/elastix.zip"
	curl "$elastix_url" -L -# -o "$elastix_zip_path"
	echo "Unzipping Elastix in $path_install" #Any archive of Elastix are not in one directory
	mkdir -p "$path_install/$elastix_os_subpath/"
	unzip "$elastix_zip_path" -d "$path_install/$elastix_os_subpath/"
fi

if [[ -f "$elastix_path" ]]; then
    echo "Elastix successfully installed."
else
	echo "Elastix installation failed, please retry with administrator rights or install in a folder requiring less privilege"
	pause "Press [Enter] to end the script"
	exit 1 # We cannot proceed
fi

echo --- Setting Elastix and Transformix path in Fiji
argElastixPath="elastixPath=\"$elastix_path\""
argTransformixPath="transformixPath=\"$transformix_path\""
all_args="$argElastixPath,$argTransformixPath"
"$fiji_path" --ij2 --headless --run SetElastixPath.groovy "$all_args"

# ------ SETTING UP QUPATH ------
echo ------ Setting up QuPath ------

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	qupath_executable_file="QuPath"
	qupath_url="https://github.com/qupath/qupath/releases/download/v${qupath_version}/QuPath-v${qupath_version}-Linux.tar.xz"
	qupath_path="$path_install/QuPath/bin/$qupath_executable_file"
	if [[ -f "$qupath_path" ]]; then
		echo "QuPath detected, bypassing installation"
	else
		echo "QuPath not present, downloading it from $qupath_url"
		qupath_zip_path="$temp_dl_dir/QuPath-${qupath_version}-Linux.tar.xz"
		curl "$qupath_url" -L -# -o "$qupath_zip_path"
		echo "Unzipping QuPath"
		tar -f "$qupath_zip_path" -C "$path_install/" -xv
		echo "We give execution right"
		chmod u+x "$path_install/QuPath/bin/QuPath"
		chmod u+x "$path_install/QuPath/bin/QuPath.sh"
		echo "[Desktop Entry]
Type=Application
Name=QuPath
Comment=QuPath
Icon=$path_install/QuPath/lib/QuPath.png
Exec=$qupath_path.sh
Terminal=false  #ouvrir ou non un terminal lors de l'exécution du programme (false ou true)
StartupNotify=false  #notification de démarrage ou non (false ou true)
Categories=Analyse image  #Exemple: Categories=Application;;" > ~/.local/share/applications/QuPath.desktop
		if [[ -f "$qupath_path" ]]; then
			echo "QuPath successfully installed"
		else
			echo "QuPath installation failed, please retry with administrator rights or install in a folder requiring less priviledge"
			pause "Press [Enter] to end the script"
			exit 1 # We cannot proceed
		fi
	fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
	qupath_executable_file="Contents/MacOS/QuPath"
	qupath_url="https://github.com/qupath/qupath/releases/download/v${qupath_version}/QuPath-v${qupath_version}-Mac.pkg"
	qupath_path="/Applications/QuPath.app/$qupath_executable_file"
	echo "$qupath_path"
	if [[ -f "$qupath_path" ]]; then
		echo "QuPath detected, bypassing installation"
	else
		echo "QuPath not present, downloading it from $qupath_url"
		qupath_zip_path="$temp_dl_dir/qupath.pkg"
		curl "$qupath_url" -L -# -o "$qupath_zip_path"
		echo "Installing QuPath, you will need to enter your admin password for the install (or install QuPath before running the script)"
		sudo installer -pkg "$qupath_zip_path" -target /
		if [[ -f "$qupath_path" ]]; then
			echo "QuPath successfully installed"
		else
			echo "QuPath installation failed, please retry with administrator rights or install in a folder requiring less privilege"
			pause "Press [Enter] to end the script"
			exit 1 # We cannot proceed
		fi
	fi
elif [[ "$OSTYPE" == "msys" ]]; then
	qupath_executable_file="QuPath-${qupath_version}.exe"
	qupath_url="https://github.com/qupath/qupath/releases/download/v${qupath_version}/QuPath-v${qupath_version}-Windows.zip"
	qupath_path="$path_install/QuPath-${qupath_version}/$qupath_executable_file"
	if [[ -f "$qupath_path" ]]; then
		echo "QuPath detected, bypassing installation"
	else
		echo "QuPath not present, downloading it from $qupath_url"
		qupath_zip_path="$temp_dl_dir/qupath.zip"
		curl "$qupath_url" -L -# -o "$qupath_zip_path"
		echo "Unzipping QuPath"
		unzip "$qupath_zip_path" -d "$path_install/QuPath-${qupath_version}"
		if [[ -f "$qupath_path" ]]; then
			echo "QuPath successfully installed"
		else
			echo "QuPath installation failed, please retry with administrator rights or install in a folder requiring less priviledge"
			pause "Press [Enter] to end the script"
			exit 1 # We cannot proceed
		fi
	fi	
fi

echo ------ Setting up QuPath extension ------

# See https://imagej.net/scripting/headless to deal with the mess of single quotes vs double quotes
argQuPathUserPath="defaultQuPathUserPath=\"$path_install/QuPath Common Data_0.5\""
argQuPathPrefNode="quPathPrefsNode=\"io.github.qupath/0.5\""
argQuPathExtensionURL="quPathExtensionURL=\"$qupath_warpy_extension_url\""
argQuitAfterInstall="quitAfterInstall=\"true\""
all_args="$argQuPathUserPath,$argQuPathPrefNode,$argQuPathExtensionURL,$argQuitAfterInstall"
"$fiji_path" --ij2 --headless --run InstallQuPathExtension.groovy "$all_args"

echo "Removing temporary download folder $temp_dl_dir"
rm -r "$temp_dl_dir"

echo ------ INSTALLATION DONE ------
echo "You should be able to run either Fiji or QuPath and access Warpy's functionalities"
echo "If this script failed, please post the errors in forum.image.sc"
