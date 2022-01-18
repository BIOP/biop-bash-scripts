#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "${SCRIPT_DIR}"
echo "You need admin privilege to install QuPath, please enter your password"
sudo "./install_warpy.sh"
