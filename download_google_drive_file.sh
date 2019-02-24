#!/bin/env bash

download() {
FILEID="$(echo $FILEID | sed -n 's#.*\https\:\/\/drive\.google\.com/file/d/\([^.]*\)\/view.*#\1#;p')";
FILENAME="$(wget -q --show-progress -O - "https://drive.google.com/file/d/$FILEID/view" | sed -n -e 's!.*<title>\(.*\)\ \-\ Google\ Drive</title>.*!\1!p')";
wget -q --show-progress --save-cookies /tmp/cookies.txt --no-check-certificate "https://docs.google.com/uc?export=download&id=$FILEID" -O $FILENAME

if grep -q "Virus scan" $FILENAME ; then
  wget -q --show-progress --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(cat $FILENAME | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=$FILEID" -c -O "$FILENAME" && rm -rf /tmp/cookies.txt;
fi

if grep -q "Quota exceeded" "$FILENAME"; then
	rm $FILENAME && \
	echo "Google Drive Limited (Quota Exceeded)" && \
	echo "file $FILENAME can NOT be downloaded"
else
	echo "file $FILENAME has been downloaded"
fi
}

checkurl() {
if echo $FILEID | grep -q 'https://drive.google.com/file/d/.*/view.*'; then
	download
else
	echo "Please input 'https://drive.google.com/file/d/xxxxxxx/view'"
fi
}

if [ $# -eq 1 ];then
	FILEID=$1
	checkurl	
else
	echo "Insert the google drive full url to download";
	read FILEID
	checkurl
fi