#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "${SCRIPT_DIR}"
echo "You need admin privilege to install Fiji, please enter your password"
sudo "./install_fiji.sh"
