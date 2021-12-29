# BIOP BASH SCRIPTS

This repository contains bash scripts which should ideally simplify your life when working with QuPath and Fiji.

Ideally these scripts should automatically download, install and configure several tools, in a platform independent manner, and with minimal work.

You can get the help for any of these bash scripts with:
`./myscript.sh -h`

**IMPORTANT: on windows, you need to install the 64bits version of [Git4Windows](https://git-scm.com/download/win) in order to execute these bash scripts.**

If time allows, additional information about these scripts are detailed below.

So far, the hierarchy of bash scripts is flat in order to simplify calling a script from another one. The easiest to make sure that a script will work is to clone the repo in order to make sure that all scripts are accessible.

## install_abba.sh

This script simplifies the installation of [ABBA](https://biop.github.io/ijp-imagetoatlas/) (on windows so far, but probably also on mac if a nice contributor help us!).

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

You can specify the install path with `./install_abba.sh MyPath`, and we recommend `./install_abba.sh C:/` to avoid issues with spaces in path.
(Note: you will need admin priviledges to install on C).

The script auto detects if software are already installed, so you can safely execute it several times in case a download fails.

If you have issues with this script, please post your issue with as much details as possible in `forum.image.sc` and add the `ABBA` tag.

This script internally uses the scripts `InstallQuPathExtension.groovy` and `SetElastixPath.groovy`, which are run within Fiji.

** ONLY WINDOWS IS SUPPORTED NOW, CONTRIBUTIONS FOR MAC OS WELCOMED!"
