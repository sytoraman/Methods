#!/bin/bash
# This script should be given the name of the version of Anaconda you want to install from https://repo.continuum.io/archive/

if [ $# -ne 1 ]; then
    echo "usage:   ${0##*/} user|root"
    echo "example: ${0##*/} user"
    exit 1
fi

who=$1

scriptName="$(basename $0)"
scriptDir="$(dirname "$0")"
mkdir ~/tmp
cd ~/tmp
# Install as root user 
sudo curl -O https://repo.continuum.io/archive/$scriptName

# shaResult=`sha256sum "$scriptName"`

# echo You will know that Anaconda is uncorrupted if the shaResult below matches the correct SHA at https://docs.anaconda.com/anaconda/install/hashes/
# echo $shaResult
# echo '' 
# echo Hit return when you have checked that the downloaded file is uncorrupted
# read answer

if [ "$who" == "root" ]; then 
    sudo bash ~/tmp/$scriptName -b -u -p /usr/local/anaconda3

    sudo /usr/local/anaconda3/bin/conda create -n py27 python=2.7 anaconda

    # Add anaconda to paths both for root and for all other users
    if [ ! $(uname -s) = "Darwin" ]; then # Not MacOS, assume Linux
	[ -d /usr/local/anaconda3/bin ] && sudo cp -p $scriptDir/Anaconda3_root_PATH.sh /etc/profile.d/Anaconda3.sh
	if grep -q '/usr/local/anaconda3/bin' /etc/environment; then
	    echo ''
	    echo '/usr/local/anaconda3/bin is already in the path, so not adding'
	    echo ''
	else # Add to root path -- only way to do this in ubuntu seems to be by changing /etc/environment
	    sudo chmod u+w /etc/environment
	    sudo sed -e 's\/usr/local/sbin:\/usr/local/anaconda3/bin:/usr/local/sbin:\g' /etc/environment > ~/tmp/environment
	    sudo mv ~/tmp/environment /etc/environment # Weird permissions issue prevents direct redirect into /etc/environment
	    sudo chmod u-w /etc/environment
	fi
    fi

    source /etc/environment
    # sudo conda install -c conda-forge jupyter_contrib_nbextensions

    sudo rm -Rf ~/tmp
else #
    echo '-b batch mode'
    echo '-u update existing installation'
    echo '-t run package tests after installation'
    cmd="sudo bash ~/tmp/$scriptName -b -u -p ~/"
    echo $cmd
    eval $cmd
fi

source ~/.bashrc
sudo chmod a+w -Rf /usr/local/anaconda*

sudo conda update conda
sudo conda update anaconda

conda install -c anaconda scipy
conda install -c pyopengl # Otherwise you get an error "Segmentation fault (core dumped)"
