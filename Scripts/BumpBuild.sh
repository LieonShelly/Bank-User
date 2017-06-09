#!/bin/bash
 
#  update_build_number.sh
#  Usage: `update_build_number.sh [branch]`
#  Run this script after the 'Copy Bundle Resources' build phase
#  Ref: http://tgoode.com/2014/06/05/sensible-way-increment-bundle-version-cfbundleversion-xcode/

branch=${1:-'develop'}
REV=$(git rev-list $branch --count)
HEAD=$(git rev-list HEAD..$branch --count)
BUILD=$(expr $REV - $HEAD + 318)
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD" "${INFOPLIST_FILE}"