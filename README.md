# BIOP BASH SCRIPTS

This repository contains bash scripts which should ideally simplify your life when working with [QuPath]() and [Fiji](https://imagej.net/software/fiji/).

> Windows and  Mac-OSX supported, contributions for Linux welcomed!

These scripts should automatically download (internet connection required!), install, update and configure several tools, in a platform independent manner.

**If you have issues with these scripts, please post your issue with as much details as possible (script used, your OS + error messages) in [`forum.image.sc`](https://forum.image.sc/)**

To execute scripts, download the full repository as zip (green Code button > Download ZIP) and do not forget to unzip the zip file before running any of these scripts!

## Windows
You need to install the 64bits version of [Git4Windows](https://git-scm.com/download/win) in order to execute these bash scripts. (`.sh` files). You can keep all settings to the default ones with the installer. Then simply double click the `.sh` file of your choice.

## Mac-OSX
You need to right-click a `.command` file and select `Open`. Then you can force the execution of the scripts. Otherwise the OS will prevent you from executing the scripts. Do not double-click the `.sh` files since it will open a text editor.

If you get an error message, please [grant the terminal application with full disk access](https://osxdaily.com/2018/10/09/fix-operation-not-permitted-terminal-error-macos/)

## Linux
Simply executing the sh scripts should work, but this has not been tested.

## Scripts help
You can get a help for any of these bash scripts on a terminal with:
`./myscript.sh -h`

> **You have to close Fiji and QuPath when executing these scripts**. Otherwise jars cannot be deleted correctly during updates.

## Installation Path
Each script can take a path as an argument for the installation. Otherwise a path will be asked. We highly recommend the following path:

* Windows: `C:/`
* Mac-OSX: `/Applications/`

If you install on a path with space characters, use double quotes, for instance:

`./full_install.sh "C:/Program Files/"`

## Scripts hierarchy

The `full_install*` scripts are executing sequentially downstream install scripts. If you are interested in Fiji only, you can directly execute a downstream script (like only `install_fiji`). 

The way scripts are calling one another is shown below:

```bash
full_install
├── full_install_biop_fiji
│   ├── install_fiji
│   └── install_fiji_update_sites
├── full_install_biop_qupath
│   ├── install_qupath
│   └── install_qupath_extensions
└── full_install_abba
    ├── install_abba (which install Fiji and QuPath)
    └── install_abba_atlases
```

If you run the `full_install` script you will thus run all scripts sequentially, except `install_warpy`.

`install_warpy` is an isolated script because it is installing a subset of the components of ABBA. So, if you use `install_abba`, you will get Warpy as well, but if you want Warpy only, you can use the warpy script instead.

> Running scripts multiple times is safe. Pre-installed components are automatically detected and will not be downloaded a second time. However Fiji is always updated multiple times for each re-run, which can take some time.

# I want it all! 

If you want a machine set up with Fiji and QuPath and extensions like the default one we have at the facility, just run:

**full_install**

And specify a path.

# Fiji

## full_install_biop_fiji

This script downloads, updates and installs Fiji version with a selection of update sites.

### install_fiji

Downloads Fiji and updates it.

### install_fiji_update_sites

Adds a selection of update sites to the predownloaded Fiji. To know (or modify) the list of updates, check the `install_fiji_update_sites` script on a text editor.

# QuPath 

## full_install_biop_qupath

**Warning: Fiji needs to be installed on the same path**

This script downloads and install QuPath version v0.3.

### install_qupath

Downloads QuPath and installs it.

### install_qupath_extensions
**Warning: Fiji needs to be installed on the same path**
This is because the qupath extensions are installed from Fiji.
This script adds a selection of extensions to QuPath (check the help to get the list).

# [Warpy](https://c4science.ch/w/warpy/)

## install_warpy

This script downloads, install, and configure all components needed to use [Warpy](https://c4science.ch/w/warpy/):
* Fiji (+ Bigdataviewer-Playground update site)
* QuPath (+ Warpy extension)
* Elastix

# [ABBA](https://biop.github.io/ijp-imagetoatlas/) 

## full_install_abba

This script downloads, install, and configure all components needed to use [ABBA](https://biop.github.io/ijp-imagetoatlas/).

### install_abba

This script simplifies the installation of [ABBA](https://biop.github.io/ijp-imagetoatlas/) 

> With a manual install on windows, one would need to:
> * install Fiji
> * install QuPath
> * install vc_redist_64.exe (necessary for elastix)
> * install elastix and transformix
> * enable the ABBA update site on Fiji
> * set the elastix path on Fiji
> * install the qupath ABBA extension in QuPath
> 
> The full procedure is explained here: https://biop.github.io/ijp-imagetoatlas/installation.html

With this script, you can simply run `install_abba` and all of the procedure above, including the downloads, will be performed automatically.

This script internally uses the scripts `InstallQuPathExtension.groovy` and `SetElastixPath.groovy`, which are run within Fiji.

> If you prefer a half automated install for more flexibility on the software installs, check https://github.com/enassar/ABBA-QuPath-utility-scripts, which performs automated downloads.

### install_abba_atlases

This script can be executed after `install_abba` in order to pre-download the [Allen adult mouse brain atlas CCFv3](http://help.brain-map.org/download/attachments/2818171/MouseCCF.pdf) and the [Waxholm Space atlas of the Sprague Dawley Rat Brain V4](https://www.nitrc.org/projects/whs-sd-atlas/). If you do not use this script, the download can be started from Fiji directly.
