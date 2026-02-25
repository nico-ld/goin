goin_help() {
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

last_path() {
    local memory_file="$HOME/.goin_memory"
    local last=""

    if [[ ! -f "$memory_file" ]]; then
        echo "ERROR : to use this option, you need to use the function at least one time."
        return 3;
    else
        last=$(<"$memory_file")
        cd "$last"
    fi
}

goin() {
    local include_hidden=false
    
    if [[ -z "$1" ]]; then 
        echo "ARGUMENT ERROR: no directory given."
        echo "Usage: goin [option] <directory_name>"
        return 1
    fi

    # Flag parsing
    case "$1" in
        -a|--all)
            include_hidden=true
            ;;
        -h|--help)
            goin_help
            return 0
            ;;
        -l|--last)
            last_path
            return $?
            ;;
        -*)
            echo "Invalid Flag"
            return 2
            ;;
    esac

    # Find directories, conditionally excluding hidden ones
    local paths
    if [[ "$include_hidden" == true ]]; then
        paths=(${(f)"$(find ~ -type d -name "$1" 2>/dev/null)"})
    else
        paths=(${(f)"$(find ~ -type d -not -path '*/.*' -name "$1" 2>/dev/null)"})
    fi
    
    if [[ ${#paths[@]} -eq 0 ]]; then
        echo "No such directory named $1."
        return 1
    fi
    
    if [[ ${#paths[@]} -eq 1 ]]; then
        cd "$paths[1]"
        echo "$paths[1]" > ~/.goin_memory
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
        echo "$paths[$choice]" > ~/.goin_memory
    else
        echo "INPUT ERROR: $choice is an invalid choice."
        return 1
    fi
}