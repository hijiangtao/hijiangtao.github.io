#!/bin/sh
###########################
cd ./
# switch to branch you want to use
git checkout master
# add all added/modified files
git add .
# commit changes
# read commitMessage
now = date +"%Y-%m-%d %H:%M:%S"
git commit -am "[update post] - `date +"%Y-%m-%d %H:%M:%S"`"
# push to git remote repository
git push origin master
###########################
echo "Press Enter..."
read