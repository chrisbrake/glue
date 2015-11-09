#!/bin/bash

blogName="blog"
masterBranch="/home/storage/$blogName"
productionBranch="~/$blogName"

GIT="/usr/bin/git"
TAR="/usr/bin/tar"
VERBOSE_LOG="/dev/null"

function logMessage {
    /usr/bin/logger "$@"
}

function changeDetected {
    logMessage "Fetching origin/master."
    {
    pushd $productionBranch
    $GIT remote update
    } >> $VERBOSE_LOG
    
    logMessage "Checking for updates."
    {
    ahead=$($GIT rev-list --count origin/master..master)
    behind=$($GIT rev-list --count master..origin/master)
    } >> $VERBOSE_LOG
    
    if [ $ahead -eq 0 ] && [ $behind -eq 0 ]; then
        logMessage "No changes detected for $blogName."
        return 1
    else
        logMessage "There are pending updates for $blogName."
        return 0
    fi
}

function freshCheckout {
    if [ -d "$productionBranch" ]; then
        logMessage "Found production branch."
        return 1
    else
        logMessage "Production branch does not exist, creating."
        }
        mkdir $productionBranch
        pushd $productionBranch
        $GIT checkout $masterBranch 
        } >> $VERBOSE_LOG
        return 0
    fi
}
#Enter Here
if changeDetected || freshCheckout; then
    #Update the site
else 
    exit 0
fi 
