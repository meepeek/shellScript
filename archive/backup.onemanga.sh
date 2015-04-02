#!/bin/bash
#
# usage: onemanga [-dlos] [-c <first chapter>[+|-<last chapter>]] <manga name> [<manga name> ...]
#

trap cleanup 0

base_url="http://www.onemanga.com"
search_url="$base_url/directory"
base_dir=`pwd`
log="$base_dir/onemanga.log"

CLEAREOL="`tput el`"

function calc() {
  echo "scale=2; $*" | bc -q 2>/dev/null | cut -f1 -d.
}

function echoes() {
  if [[ $2 -gt 0 ]]; then
    eval "for i in {${3:-1}..$2}; do echo -n '$1'; done"
  fi
}

function progressbar() {
  width=20
  current=$1
  total=$2

  percent=`calc "$current / $total * 100"`
  stack=`calc "$current / $total * $width"`
  stack=${stack:=0}
  space=`calc "$width - $stack"`
  
  echoes " " ${#percent} 3
  echo -n "$percent% ["
  echoes "#" $stack
  echoes " " $space
  echo "]"
}

function cleanup() {
  rm -f *.jpg tmp_* index.html
}

while getopts ":c:dlos:" op; do
  case $op in
    c)
      CHAPTER=1
      CHAPTER_ARG="$OPTARG"
      ;;
    d)
      USE_DIR=1
      ;;
    l)
      LATEST=1
      ;;
    o)
      LOG_FILE=1
      ;;
    s)
      SEARCH=1
      KEYWORD="$OPTARG"
      ;;
    \?)
      echo "Unknown option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      case $OPTARG in
        c)
          echo "Please specify a chapter number"
          ;;
        s)
          echo "Please specify a search keyword"
          ;;
      esac
      exit 1
      ;;
  esac
done

shift $(($OPTIND - 1))

if [[ $CHAPTER -eq 1 && $LATEST -eq 1 ]]; then
  echo "Invalid option: -c and -l cannot be used at the same time" >&2
  exit 1
fi

if [[ $SEARCH ]]; then
  echo -e "\nSearching ${search_url}...\n"
  wget -qO - "${search_url}/" | grep "ch-subject" | sed -e 's@^.*href\=\"/@\(@g' -e 's@</a>.*@@g' -e 's@/.*>@\):@g' | awk -F: '{print $2 "\t" $1}' | sed "s/\&\#39\;/'/g" | grep -i "$KEYWORD" > tmp_search
  [[ -s tmp_search ]] && cat tmp_search && echo ""
  result=`cat tmp_search | wc -l`
  echo -n "${result}" && [[ $result -gt 1 ]] && echo " results." || echo " result."
  exit
fi

if [[ $CHAPTER = "" && $LATEST = "" ]]; then
  UPDATE=1
fi

if [[ $CHAPTER -eq 1 ]]; then
  if [[ "${CHAPTER_ARG%+*}" != "$CHAPTER_ARG" ]]; then 
    first_chapter=${CHAPTER_ARG%+*}
    last_chapter="+"
  elif [[ "${CHAPTER_ARG%-*}" != "$CHAPTER_ARG" ]]; then 
    first_chapter=${CHAPTER_ARG%-*}
    last_chapter=${CHAPTER_ARG#*-}
  else
    first_chapter=$CHAPTER_ARG
    last_chapter=$CHAPTER_ARG
  fi
fi

for manga_name in "$@"; do
  manga_name=${manga_name%/}

  if [[ $USE_DIR -eq 1 ]]; then
    if [[ -f "$base_dir/$manga_name" ]]; then
      echo -e "\n$manga_name [SKIPPED]"
      echo "Not a directory"
      continue
    fi

    mkdir -p "$base_dir/$manga_name"
    cd "$base_dir/$manga_name"
  fi

  display_name=`echo $manga_name | sed -e "s/_/ /g" -e "s/%27/'/g"`
  word_count=`echo $display_name | wc -w`
  sort_key=$((word_count + 1))
  local_chapter=`ls ${manga_name}_*.cb? 2> /dev/null | sort -r -n -k $sort_key -t_ | head -n1`
  local_chapter=${local_chapter##*_}
  local_chapter=${local_chapter%.*}

  if [[ -n $local_chapter ]]; then
    if [[ `echo "$local_chapter == 0" | bc` -eq 0 ]]; then
      local_chapter=`echo $local_chapter | sed "s/^0*//g"`
    fi
  else
    local_chapter="none"
  fi

  echo -ne "\nOpening $base_url/$manga_name..."
  wget -qN --no-cache $base_url/$manga_name/
  
  if [[ ! -f "index.html" ]]; then
    echo -e "\b\b\b [ERROR]\n\nPlease make sure the manga name \"${manga_name}\" is spelled correctly.\nOtherwise, there may be a problem with your internet connection."
    exit 1
  fi

  grep "ch-subject" index.html 2> /dev/null | grep "a href" | cut -f3 -d\/ > tmp_chapters
  
  if [[ ! -s tmp_chapters ]]; then
    echo -e "\b\b\b [ERROR]\n\nCannot extract chapter list from the specified URL."
    exit 1
  fi
  
  echo -e "\b\b\b [OK]"

  latest_chapter=`head -1 tmp_chapters`
  
  if [[ -n $local_chapter && ! $CHAPTER -eq 1 ]]; then
    echo "Local chapter: ${local_chapter} / Latest chapter: $latest_chapter"
    
    if [[ $local_chapter == $latest_chapter ]]; then
      echo "No update."
      cleanup
      continue
    fi
  fi

  if [[ $LATEST -eq 1 ]]; then
    first_chapter=$latest_chapter
    last_chapter=$latest_chapter
  fi

  if [[ "$last_chapter" == "+" ]]; then
    last_chapter=$latest_chapter
  fi

  if [[ $UPDATE -eq 1 ]]; then
    if [[ $local_chapter == "" ]]; then
      first_chapter=`sort -n tmp_chapters | head -n1`
    else
      index=`sort -n tmp_chapters | grep -nm1 $local_chapter | cut -f1 -d:`
      first_chapter=`sort -n tmp_chapters | tail -n+$((index + 1)) | head -n1`
    fi

    last_chapter=$latest_chapter
  fi
  
  if [[ $CHAPTER -eq 1 || -z $local_chapter ]]; then
    echo "From chapter: $first_chapter / To chapter: $last_chapter"
  fi

  index=`sort -n tmp_chapters | grep -nm1 $first_chapter | cut -f1 -d:`
  last_index=`sort -n tmp_chapters | grep -nm1 $last_chapter | cut -f1 -d:`

  CHAPTERS=`sort -n tmp_chapters | awk 'FNR >= '$index' && FNR <= '$last_index`

  for chapter in $CHAPTERS; do
    echo "Downloading $display_name chapter $chapter"
    echo -ne "\r$CLEAREOL`progressbar 0 1` (Initializing...)"
    page_location=`wget -qO - $base_url/$manga_name/$chapter/ | grep -i "begin reading" | cut -f2 -d\"`
    wget -qO - $base_url$page_location | sed '/id="id_page_select"/,/\/select/ s/\<option value=/\
\<option value=/g' > tmp_page
    PAGES=`sed -n '/id="id_page_select"/,/\/select/ p' < tmp_page | grep -i "option value" | cut -f2 -d\"`
    image_location=`grep -i "manga-page" tmp_page | cut -f4 -d\"`
    image_location=${image_location%/*.jpg}
    
    total=`echo $PAGES | wc -w`
    i=0

    for page in $PAGES; do
      let i++
      echo -ne "\r$CLEAREOL`progressbar $i $total` ($i/$total)"
      wget -q "$image_location/$page.jpg"
    done

    int_part=${chapter%\.*}
    if [[ `echo "$int_part == 0" | bc` -eq 0 && ${#int_part} -lt 3 ]]; then
      chapter=`echoes "0" ${#int_part} 2`$chapter
    fi

    archive_name="${manga_name}_${chapter}.cbz"

    echo -ne "\r$CLEAREOL`progressbar $i $total` (Creating archive...)"
    if zip -q $archive_name *.jpg; then
      cleanup
      echo -e "\r$CLEAREOL`progressbar $i $total` ($archive_name)"
      [[ $LOG_FILE -eq 1 ]] && echo "[`date +%c`] $archive_name" >> "$log"
    fi
  done
done
