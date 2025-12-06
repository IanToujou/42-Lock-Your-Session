#! /bin/bash

tput civis

display_frame(){
	local text=("$@")
	local rows=${#text[@]}
	local cols=${#text[0]}
	local start_row=$(( ( $(tput lines) - rows ) / 2 ))
	local start_col=$(( ( $(tput cols) - cols) / 2))
	clear

	for (( i=0; i<rows; i++)); do
		tput cup $(( start_row + i )) $start_col
		echo -e "${text[$i]}"
	done
	sleep 0.06
}

animation=$(cat movie_name)
cd $animation/

frames=$(cat frameList)

while true; do

	for frame in $frames; do
		frameText=()
		while IFS= read -r line; do
			frameText+=("$line")
		done < "$frame"

		display_frame "${frameText[@]}"
	done
done
tput cnorm
