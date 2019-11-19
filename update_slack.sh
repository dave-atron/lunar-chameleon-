#! /bin/bash

#Read the header information from the download link and get the address of the redirect where the newest version of Slack lives
REDIR="$(curl https://slack.com/ssb/download-osx -i | grep -Fi Location: | cut -d " " -f2-)"
#Trim the trailing return character from the string
REDIR=${REDIR%$'\r'}
#Trim the redirect link so that it only contains the filename
FILE="$(echo $REDIR | cut -d "/" -f5)"

#Change directory to /.bsi
cd /.tmp
#If the filename that will be used already exists in /.bsi, do nothing
if [[ -n $(find ./ -name "$FILE") ]] || [[ ! -d $(find /Applications -name Slack.app) ]]
then 
	exit
else 
	#Download the newest version of Slack using its default file name to the working directory
	curl -O $REDIR
	#Mount the disk image
	hdiutil attach $FILE -nobrowse
	#Kill Slack
	killall Slack
	#Copy Slack.app into the applications folder
	cp -r /Volumes/Slack.app/Slack.app /Applications
	#Unmount the disk image
	hdiutil detach /Volumes/Slack.app
	#Grabs the currently logged in user
	CLIENT="$(scutil <<< "show State:/Users/ConsoleUser" | awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}')"
	#Changes the owner of Slack.app to the currently logged in user
	chown -R $CLIENT:staff /Applications/Slack.app
	#Grants standard read and execute permissions in case $CLIENT was null and owner was changed to root
	chmod -R 755 /Applications/Slack.app
	#Reopen Slack
	open -a Slack
	#Find filenames matching the pattern "Slack-*" that are more than 60 minutes old and delete them
	find ./ -mmin +60  -name "Slack-*" -delete
fi
