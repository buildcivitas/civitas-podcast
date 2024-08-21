#!/usr/bin/env zsh
set -e # halt script on error
set -x

post=$1
dir=`dirname $post`

# https://superuser.com/questions/272485/bin-sh-source-from-stdin-from-other-program-not-file
eval "`yq -r $post -o=shell `"

eval "`yq -r $dir/channel.yml -o=shell `"

echo $url | sed -e 's/:/\\\\:/' | read url

description=`pandoc $post -t markdown`
html_desc=`pandoc $post`

file=$dir/`basename -s md $post`mp3

eyeD3 --remove-all $file

eyeD3 --track $episode \
      --add-image "kiwi.jpg:FRONT_COVER"  \
      --title "$title" \
      --artist "$artist" \
      --recording-date "$recording_date"\
      --release-date "$release_date"\
      --comment "$comment" \
      --text-frame="TDES:$html_desc" \
      --text-frame="TDRL:$release_date" \
      --url-frame "WOAF:$episode_url" \
      --album "Civitas" \
      --genre 186 \
      $file

## This thing vvvvv doesn't really work for most podcatchers.
#      --text-frame="TIT3:$description" 

eyeD3 -P itunes-podcast $file --add

dropcaster $dir --channel-template templates/channel.rss.erb \
    | xmllint --format - > index.rss
