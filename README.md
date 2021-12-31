# BIOP BASH SCRIPTS

**ONLY WINDOWS IS SUPPORTED, CONTRIBUTIONS FOR MAC OS WELCOMED!**

This repository contains bash scripts which should ideally simplify your life when working with QuPath and Fiji.

Ideally these scripts should automatically download, install and configure several tools, in a platform independent manner, and with minimal work.

You can get the help for any of these bash scripts with:
`./myscript.sh -h`

**IMPORTANT: on windows, you need to install the 64bits version of [Git4Windows](https://git-scm.com/download/win) in order to execute these bash scripts.**

So far, the hierarchy of bash scripts is flat in order to simplify calling a script from another one. The easiest to make sure that a script will work is to download the full repo in order to make sure that all scripts are accessible.

**WARNING: PLEASE CLOSE AND QUPATH WHEN EXECUTING THESE SCRIPTS**
Otherwise jars cannot be deleted correctly. 

--------------- 
I want it all! 
--------------

If you want a machine set up with Fiji and QuPath and extensions like the default one we have at the facility, just run:

**./full_install.sh**

And specify a path. We recommend `C:/` (with admin priviledge).

The full install script executes sequentially:

- `full_install_biop_fiji.sh`
- `full_install_biop_qupath.sh`
- `full_install_abba.sh`

Normally running it multiple times is safe. Pre-installed components will be skipped (except for updating Fiji, which can take some time).

--------------- 
FIJI 
--------------------

# full_install_biop_fiji.sh

This script downloads and install the standard 'BIOP' Fiji version (If you specify `C:/` as the installation path). It calls sequentially the two scripts following:

- `install_fiji.sh`
- `install_fiji_update_sites.sh`

## install_fiji.sh

Downloads Fiji and updates it.

## install_fiji_update_sites.sh

Adds a selection of update sites to the predownloaded Fiji (check the help to get the list)

--------------- 
QuPath 
--------------------

# full_install_biop_qupath.sh

**Warning: Fiji needs to be installed on the same path**

This script downloads and install QuPath version v0.3.1 (If you specify `C:/` as the installation path). It calls sequentially the two scripts following:

- `install_qupath.sh`
- `install_qupath_extensions.sh`

## install_qupath.sh

Downloads Fiji and install it.

## install_qupath_extensions.sh
**Warning: Fiji needs to be installed on the same path**
This is because the qupath extensions are installed from Fiji.
Adds a selection of extensions to QuPath (check the help to get the list)

---------------- 
ABBA 
-------------------

# full_install_abba.sh

This script downloads, install, and configure all components needed to use [ABBA](https://biop.github.io/ijp-imagetoatlas/).
On windows, it is recommend to specifiy `C:/` as the installation path. It calls sequentially the two scripts following:

- `install_abba.sh`
- `install_abba_atlases.sh`

## install_abba.sh

This script simplifies the installation of [ABBA](https://biop.github.io/ijp-imagetoatlas/) 

With a manual install on windows, one would need to:
- install Fiji
- install QuPath
- install vc_redist_64.exe (necessary for elastix)
- install elastix and transformix
- enable the ABBA update site on Fiji
- set the elastix path on Fiji
- install the qupath ABBA extension in QuPath

The full procedure is explained here: https://biop.github.io/ijp-imagetoatlas/installation.html

With this script, you can simply run `./install_abba.sh` and all of the procedure above, including the downloads, will be performed automatically.

You can specify the install path with `./install_abba.sh MyPath`, and we recommend `./install_abba.sh C:/` to avoid issues with spaces in path. (Note: you will need admin priviledges to install on C).

The script auto detects if any software is already installed, so you can safely execute the script several times in case a download fails.

If you have issues with this script, please post your issue with as much details as possible in `forum.image.sc` and add the `ABBA` tag.

This script internally uses the scripts `InstallQuPathExtension.groovy` and `SetElastixPath.groovy`, which are run within Fiji.

NOTE: If you would like a half automated install for more flexibility on the software installs, check https://github.com/enassar/ABBA-QuPath-utility-scripts, which performs automated downloads.

## install_abba_atlases.sh

This script can be executed after `install_abba.sh` in order to pre-download the Allen adult mouse brain atlas CCFv3 and the Waxholm Space atlas of the Sprague Dawley Rat Brain V4. If you do not use this script, the download can be started from Fiji directly.
