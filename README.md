# BIOP BASH SCRIPTS

This repository contains bash scripts which should ideally simplify your life when working with [QuPath]() and [Fiji](https://imagej.net/software/fiji/).

> Windows and  Mac-OSX supported, contributions for Linux welcomed!

These scripts should automatically download (internet connection required!), install, update and configure several tools, in a platform independent manner.

**If you have issues with these scripts, please post your issue with as much details as possible in [`forum.image.sc`](https://forum.image.sc/) and add the `ABBA` tag.**

You can get a help for any of these bash scripts with:
`./myscript.sh -h`

>  For Windows, you need to install the 64bits version of [Git4Windows](https://git-scm.com/download/win) in order to execute these bash scripts. (`.sh` files). You can keep all settings to the default ones with the installer.

To execute scripts, download the full repository as zip (green Code button > Download ZIP) and do not forget to unzip the zip file before running any of these scripts!

> You have to close Fiji and QuPath when executing these scripts. Otherwise jars cannot be deleted correctly during updates.

Each script requires a path as an argument for the installation. We recommend the following path:

* Windows: `C:/`
* Mac-OSX: `/Applications/`

If you install on a path with space characters, use double quotes, for instance:

`./full_install.sh "C:/Program Files/"`

If you execute a script without specifying any path, you will be asked for one.

The `full_install*` scripts are executing sequentially downstream install scripts. If you are interested in Fiji only, you can directly execute a downstream script. The way scripts are calling one another is shown below:

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

Running scripts multiple times is safe. Pre-installed components are automatically detected and will not be downloaded a second time. However Fiji is always updated multiple times for each re-run, which can take some time.

# I want it all! 

If you want a machine set up with Fiji and QuPath and extensions like the default one we have at the facility, just run:

**./full_install.sh**

And specify a path.

# Fiji

## full_install_biop_fiji.sh

This script downloads, updates and installs Fiji version with a selection of update sites.

### install_fiji.sh

Downloads Fiji and updates it.

### install_fiji_update_sites.sh

Adds a selection of update sites to the predownloaded Fiji. To know (or modify) the list of updates, check the `install_fiji_update_sites.sh` script on a text editor.

# QuPath 

## full_install_biop_qupath.sh

**Warning: Fiji needs to be installed on the same path**

This script downloads and install QuPath version v0.3.1.

### install_qupath.sh

Downloads QuPath and installs it.

### install_qupath_extensions.sh
**Warning: Fiji needs to be installed on the same path**
This is because the qupath extensions are installed from Fiji.
This script adds a selection of extensions to QuPath (check the help to get the list).

# ABBA 

## full_install_abba.sh

This script downloads, install, and configure all components needed to use [ABBA](https://biop.github.io/ijp-imagetoatlas/).

### install_abba.sh

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

With this script, you can simply run `./install_abba.sh` and all of the procedure above, including the downloads, will be performed automatically.

This script internally uses the scripts `InstallQuPathExtension.groovy` and `SetElastixPath.groovy`, which are run within Fiji.

> If you prefer a half automated install for more flexibility on the software installs, check https://github.com/enassar/ABBA-QuPath-utility-scripts, which performs automated downloads.

### install_abba_atlases.sh

This script can be executed after `install_abba.sh` in order to pre-download the [Allen adult mouse brain atlas CCFv3](http://help.brain-map.org/download/attachments/2818171/MouseCCF.pdf) and the [Waxholm Space atlas of the Sprague Dawley Rat Brain V4](https://www.nitrc.org/projects/whs-sd-atlas/). If you do not use this script, the download can be started from Fiji directly.
