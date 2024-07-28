#!/bin/bash

usage() {
	echo "usage: $(basename "$0") [-l LANG | -m MODEL | -h] file"
}
BASE_DIR="$(dirname "$(realpath "$0")")" # support symlink

lang="auto"
model="$BASE_DIR/models/ggml-small.bin"
while getopts ':l:m:h' OPT; do
	case $OPT in
		l) lang="$OPTARG" ;;
		m) model="$BASE_DIR/models/ggml-$OPTARG.bin" ;;
		h | ?) usage && exit ;;
	esac
done
shift $((OPTIND - 1))
infile="$*"
[ -n "$infile" ] || { usage && exit; }
[ -f "$infile" ] || { echo "File not found: $infile" && exit 1; }

extract_wav() {
	if [[ $1 == *.wav ]]; then
		cat "$1"
	else
		ffmpeg -nostdin -v error -stats -threads 0 -i "$1" -ar 16000 -ac 1 -c:a pcm_s16le -f wav -
	fi
}

echo "whisper using language: $lang, model: $(basename "$model")"
extract_wav "$infile" | $BASE_DIR/main -m $model -l $lang -f - -osrt -of "${infile%.*}"
