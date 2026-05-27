#!/bin/zsh

_find_path() {
	local root="$1"
	local wanted_dir="$2"

	# Split path
	local segments=(${(s:/:)wanted_dir})
	segments=(${(ps: :)segments})

	local seg
	local paths
	local matches=""
	local count=0
	for seg in $segments; do
		((count++))

		if [[ "${seg:0:1}" == "." ]]; then
			if ! grep -q 'HIDDEN_FLAG="true"' "$config_file"; then
				echo -e "goin: $WARNING: hidden directory detected in your path" >&2
				echo -e "goin: $INFO: hidden directory search enable" >&2
				if ! grep -q "HIDDEN_FLAG" "$config_file"; then
					echo 'HIDDEN_FLAG="true"' >> "$config_file"
				else
					sed -i 's|^HIDDEN_FLAG=".*"|HIDDEN_FLAG="true"|' "$config_file"
				fi
			fi
		fi

		# Absolute path case
		if [[ "$seg" == "home" && "$count" == 1 ]]; then
			echo "$wanted_dir"
			return 0
		fi

		# For the first iteration search in given root
		if [[ "$count" == 1 ]]; then 
			if grep -q 'HIDDEN_FLAG="true"' "$config_file"; then
				paths=(${(f)"$(find "$root" -type d -name "$seg" )"})
			else
				paths=(${(f)"$(find "$root" -type d -not -path '*/.*' -name "$seg" )"})
			fi

			# If no path founded
			if [[ ${#paths[@]} -eq 0 ]]; then
				echo -e "goin: $ERROR: No such directory named '$seg' in '$root'" >&2
				return 1
			fi
			# Else
			matches=(${(s: :)paths})

		# For others iterations search in each directory corresponding
		else
			local roots="$matches"
			local current_root
			# Reset matches at every itereation to only get last one
			unset matches

			for current_root in $roots; do
				if grep -q 'HIDDEN_FLAG="true"' "$config_file"; then
					paths=(${(f)"$(find "$current_root" -type d -name "$seg" )"})
				else
					paths=(${(f)"$(find "$current_root" -type d -not -path '*/.*' -name "$seg" )"})
				fi
				if [[ ${#paths[@]} -gt 0 ]]; then
					matches+=(${(s: :)paths})
					matches+="\n"
				fi
			done

			# If no path founded
			if [[ ${#matches[@]} -eq 0 ]]; then
				echo -e "goin: $ERROR: No such directory named '$seg' in '$root'" >&2
				return 1
			fi
		fi		
	done

	echo "$matches"
	return 0
}

# 
# _research() -> main part of function, find and go in right directory.
#               If there is several directories names as same, the function ask
#               what is the path wanted by user.
# 
_research() {
    local searching_root="$1"
    local current_dir="$2"
    local wanted_dir="$3"

    # Get root
    if [[ "$searching_root" == "~" ]]; then
        local root="$HOME"
    else
		local root="$searching_root"
    fi

	# Find directory
	local paths
	paths=$(_find_path "$root" "$wanted_dir")

	# Error
	if (( $? == 1)); then
		return 1
	fi

	# Directory founded
	paths=(${(s: :)paths})
    if [[ ${#paths[@]} -eq 1 ]]; then
        cd "$paths[1]"
        _update_config_file "$paths[1]" "$current_dir"
        return 0
    fi
    
    # Multiple matches found
    echo "Multiple matches:"
	echo "0 - Abort"
    local i
    for i in {1..${#paths[@]}}; do
        echo "$i - $paths[$i]"
    done
    
    local choice
	echo
    read "choice?Please select one path: "
    
    if [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 && "$choice" -le ${#paths[@]} ]]; then
        cd "$paths[$choice]"
        _update_config_file "$paths[$choice]" "$current_dir"
        return 0
	elif [[ "$choice" =~ ^[0-9]+$ && "$choice" -eq 0 ]]; then
		echo "goin: $INFO: Aborting"
		return 77
    else
        echo "goin: $ERROR: $choice is an invalid choice."
        return 1
    fi
}
