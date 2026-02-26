_goin_help() {
	echo -e "  \033[1mUsage:\033[0m "
    echo -e "\tgoin [option] <directory_name>\n"
	echo -e "  \033[1mDescription:\033[0m "
    echo -e "\tThis command allows you to access any directory from the root directory."
	echo -e "\tBy default, this function does not search hidden folders. You can enable this with '-all'. \n"
	echo -e "  \033[1mOptions:\033[0m"
	echo -e "\t-a --all : Include hidden directories"
	echo -e "\t-h --help : Display informations about this command"
    echo -e "\t-l --last : Use the same path than the last time you use the command\n"
	echo -e "  \033[1mAuthor\033[0m : nico-ld."
}

_last_path() {
    local memory="$HOME/.goin_memory"
    local last=""

    if [[ ! -f "$memory_file" ]]; then
        echo "ERROR : to use this option, you need to use the function at least one time."
        return 3;
    else
        last=$(<"$memory_file")
        cd "$last"
    fi
}

_update_config_file() {
    sed -i "s|^LAST_PATH=\".*\"|LAST_PATH=\"$1\"|" "$config_file"
    sed -i "s|^LAST_DIR=\".*\"|LAST_DIR=\"$2\"|" "$config_file"
}

_global_research() {
    # Find directories, conditionally excluding hidden ones
    local paths
    if [[ "$1" == "true" ]]; then
        paths=(${(f)"$(find ~ -type d -name "$4" 2>/dev/null)"})
    else
        paths=(${(f)"$(find ~ -type d -not -path '*/.*' -name "$4" 2>/dev/null)"})
    fi
    
    if [[ ${#paths[@]} -eq 0 ]]; then
        echo "No such directory named '$4'."
        return 1
    fi
    
    if [[ ${#paths[@]} -eq 1 ]]; then
        cd "$paths[1]"
        _update_config_file "$paths[1]" "$2"
        return 0
    fi
    
    # Multiple matches found
    echo "Multiple matches:"
    local i
    for i in {1..${#paths[@]}}; do
        echo "$i - $paths[$i]"
    done
    
    local choice
    read -r "?Please select one path: " choice
    
    if [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 && "$choice" -le ${#paths[@]} ]]; then
        cd "$paths[$choice]"
        _update_config_file "$paths[$choice]" "$2"
        return 0
    else
        echo "INPUT ERROR: $choice is an invalid choice."
        return 1
    fi
}

_has_new_commit() {
  # Current branch
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return 2

  # quiet fetch
  git fetch -q >/dev/null 2>&1 || return 2

  # Compare hash of commit
  local local_commit remote_commit
  local_commit=$(git rev-parse HEAD 2>/dev/null) || return 2
  remote_commit=$(git rev-parse @{u} 2>/dev/null) || return 2

  [[ "$local_commit" != "$remote_commit" ]]
}


goin() {
    local config_file="$HOME/.goin_config"

    if [[ ! -f "$config_file" ]]; then
        echo -e 'LAST_PATH="~"\nLAST_DIR="~"' > "$config_file"
    fi

    if [[ -z "$1" ]]; then 
        echo "ARGUMENT ERROR: no directory given."
        echo "Usage: goin [option] <directory_name>"
        return 1
    fi

    local current_dir=${PWD}
    local back=$(cat "$config_file" | grep LAST_DIR | cut -d '=' -f2- | tr -d '"')
    local last=$(cat "$config_file" | grep LAST_PATH | cut -d '=' -f2- | tr -d '"')

    # Flag parsing
    case "$1" in
        -a|--all)
            _global_research "true" "$current_dir" "$back" "$2"
            ;;
        -h|--help)
            _goin_help
            ;;
        -b|--back)
            cd "$back"
            _update_config_file "$back" "$current_dir"
            ;;
        -l|--last)
            cd "$last"
            _update_config_file "$last" "$current_dir"
            ;;
        -*)
            echo "Invalid Flag"
            (exit 2)
            ;;
        *)
            _global_research "false" "$current_dir" "$last" "$1"
            ;;
    esac

    local return_code="$?"

    # if _has_new_commit; then
    #     echo "An update is avaible"
    # fi
    return "$return_code"
}
