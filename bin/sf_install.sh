#!/bin/sh

# Making sure you have unarchiver

# Retrieve discord tar.gz file 

wget "https://developer.salesforce.com/media/salesforce-cli/sf/channels/stable/sf-linux-x64.tar.xz" -O sf.tar.gz

# Extract files to ~/bin/sf directory
mkdir -p ~/Applications/sf
tar -xvf sf.tar.gz -C ~/bin/sf --strip-components 1; rm sf.tar.gz

export PATH=~/bin/sf/bin:$PATH


