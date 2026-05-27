#!/bin/zsh

# 
# _research() -> main part of function, find and go in right directory.
#               If there is several directories names as same, the function ask
#               what is the path wanted by user.
# 
_research() {
    local searching_root="$1"
    local current_dir="$2"
    local wanted_dir="$3"

    # Find directories
    local paths
    if [[ "$searching_root" == "~" ]]; then
        local root="$HOME"
    else
		local root="$searching_root"
    fi

	if grep -q 'HIDDEN_FLAG="true"' "$config_file"; then
    	paths=(${(f)"$(find "$root" -type d -name "$wanted_dir" )"})
	else
    	paths=(${(f)"$(find "$root" -type d -not -path '*/.*' -name "$wanted_dir" )"})
	fi

    if [[ ${#paths[@]} -eq 0 ]]; then
        echo "goin: $ERROR: No such directory named '$wanted_dir'."
        return 1
    fi
    
    if [[ ${#paths[@]} -eq 1 ]]; then
        cd "$paths[1]"
        _update_config_file "$paths[1]" "$current_dir"
        return 0
    fi
    
    # Multiple matches found
    echo "Multiple matches:"
    local i
    for i in {1..${#paths[@]}}; do
        echo "$i - $paths[$i]"
    done
    
    local choice
    read "choice?Please select one path: "
    
    if [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 && "$choice" -le ${#paths[@]} ]]; then
        cd "$paths[$choice]"
        _update_config_file "$paths[$choice]" "$current_dir"
        return 0
    else
        echo "goin: $ERROR: $choice is an invalid choice."
        return 1
    fi
}
