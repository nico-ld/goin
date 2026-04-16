_goin_help() {
	echo -e "  \033[1mUsage:\033[0m "
    echo -e "\tgoin [option] <directory_name>"
    echo -e "\tgoin <option>"
    echo -e "\tgoin <alias> [directory_name]\n"
	echo -e "  \033[1mDescription:\033[0m "
    echo -e "\tThis command allows you to access any directory from anywhere.\n"
	# echo -e "\tBy default, this function does not search hidden folders. You can enable this with '-all'. \n"
	echo -e "  \033[1mOptions:\033[0m"
    echo -e "\t-b --back : Work like '\033[3mcd -\033[0m' but without print the destination path"
	echo -e "\t-h --help : Display informations about this command"
    echo -e "\t-l --last : Use the same path than the last time you use the command\n"
	echo -e "  \033[1mAlias :\033[0m"
    echo -e "\tYou can customise this function with somes alias. This allows you to restrict the scope \n\tof the function on a given path. You can also use them to go faster in you're directory\n"
    echo -e "\t--set-alias <name> <path> : If the alias does not exist, it is created; otherwise, its path \n\t\tis modified. The name of you're alias have to start with '-' to be reconize like a flag"
    echo -e "\t--unset-alias <name> : Delete an alias\n"
	echo -e "  \033[1mAuthor\033[0m : nico-ld."
}

# 
# _update_config_file() -> modify .goin_config to always keep goin -l and goin -b working
# 
_update_config_file() {
    sed -i "s|^LAST_PATH=\".*\"|LAST_PATH=\"$1\"|" "$config_file"
    sed -i "s|^LAST_DIR=\".*\"|LAST_DIR=\"$2\"|" "$config_file"
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

    # Find directories
    local paths
    if [[ "$searching_root" == "~" ]]; then
        paths=(${(f)"$(find ~ -type d -name "$wanted_dir" )"}) # 2>/dev/null
    else
        paths=(${(f)"$(find "$1" -type d -name "$wanted_dir" )"}) # 2>/dev/null
    fi
    
    if [[ ${#paths[@]} -eq 0 ]]; then
        echo "No such directory named '$wanted_dir'."
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
        echo "INPUT ERROR: $choice is an invalid choice."
        return 1
    fi
}

# 
# _alias_management() -> Work with .goin_function, can add/remove/rename/list alias
# 
_alias_management() {
    if [[ "$1" == "update" ]]; then
        # testing alias
        if [[ ! -d "$4" ]]; then
            echo -e "No such directory named '$4'."
            return 1
        fi

        # testing alias name
        if grep -q -- "$3" ~/.goin_config; then
            echo -e "goin: Fatal : This alias already exist"
            return 11
        fi
    
        local key="$3"
        local value="$4"

        # update alias dictionnary
        sed -i -E "
        /^ALIAS=/ {
            s|(\"$key\":\"[^\"]*\")|\"$key\":\"$value\"|;
            t done;
            s|^ALIAS=\{\}|ALIAS={\"$key\":\"$value\"}|;
            t done;
            s|^ALIAS=\{([^}]*)\}|ALIAS={\"$key\":\"$value\",\1}|;
            :done
        }
        " "$config_file"
    elif [[ "$1" == "unset" ]]; then
        # testing alias name
        if ! grep -q -- "$3" ~/.goin_config; then
            echo -e "goin: No such alias named '$3'"
            return 11
        fi

        local key="$3"
        
        sed -i -E "
        /^ALIAS=/ {
            s/,\"$key\":\"[^\"]*\"//;      # cas: , "key":"value"
            s/\"$key\":\"[^\"]*\",//;      # cas: "key":"value",
            s/\"$key\":\"[^\"]*\"//;       # cas: seul élément
            s/\{,/\{/;                    # nettoie {,
            s/,\}/\}/;                    # nettoie ,}
        }
        " "$config_file"
    elif [[ "$1" == "research" ]]; then
        if ! (grep "ALIAS" "$config_file" | grep -q -- "\"$2\":"); then
            echo -e "goin: Unkwnow flag or alias"
            return 12
        fi
        
        local target=$(grep '^ALIAS=' "$config_file" | cut -d '=' -f2- | grep -o "\"$2\":\"[^\"]*\"" | cut -d ':' -f2 | tr -d '"')
        
        local current_dir=${PWD}
        cd "$target"
        if [[ ! -z "$3" ]]; then
            _research "." "$current_dir" "$3"
        else
            _update_config_file "$target" "$current_dir"
        fi
    fi
}

#
# goin() -> main function. Parse all flags and call good function
#
goin() {
    local config_file="$HOME/.goin_config"

    if [[ ! -f "$config_file" ]]; then
        echo -e 'LAST_PATH="~"\nALIAS={}\nREPO="~/.goin_function"' > "$config_file"
    fi

    if [[ -z "$1" ]]; then 
        echo "ARGUMENT ERROR: no directory given."
        echo "Usage: goin [option] <directory_name>"
        return 3
    fi

    local current_dir=${PWD}
    local back=$(env | grep OLDPWD | cut -d '=' -f2-)
    local last=$(cat "$config_file" | grep LAST_PATH | cut -d '=' -f2- | tr -d '"')

    # Flag parsing
    case "$1" in
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
        --set-alias)
            if [[ -z "$2" || -z "$3" ]]; then
                echo -e "goin: missing arguments\nUsage: goin --set-alias <name> <path/from/home>"
                (exit 1)
            else
                _alias_management "update" $@
            fi
            ;;
        --unset-alias)
            if [[ -z "$2" ]]; then
                echo -e "goin: missing arguments\nUsage: goin --unset-alias <name>"
                (exit 1)
            else
                _alias_management "unset" $@
            fi
            ;;
        --update)
            if git -C "$HOME/.goin_function" pull -q; then
                echo "goin: successfully updated"
            fi
            ;;
        -*)
            _alias_management "research" $@
            ;;
        *)
            _research "~" "$current_dir" "$1"
            ;;
    esac

    local return_code="$?"

    return "$return_code"
}

# 
# _has_new_commit() -> Check for a new update
# 
_has_new_commit() {
    # Repository
    local repo=$(grep '^REPO=' "$HOME/.goin_config" | cut -d '=' -f2- | tr -d '"')
    if [[ ! -d ${~repo} ]]; then
        echo "goin: The config file doesn't have access to the repositorie, please indicate the new path in '~/.goin_config'"
        return 1
    fi

    # Current branch
    local branch
    branch=$(git -C ${~repo} rev-parse --abbrev-ref HEAD 2>/dev/null) || return 2

    # quiet fetch
    git -C ${~repo} fetch -q >/dev/null 2>&1 || return 2

    # Compare hash of commit
    local local_commit remote_commit
    local_commit=$(git -C ${~repo} rev-parse HEAD 2>/dev/null) || return 2
    remote_commit=$(git -C ${~repo} rev-parse @{u} 2>/dev/null) || return 2

    [[ "$local_commit" != "$remote_commit" ]]
}

if _has_new_commit; then
    echo "goin: An update is avaible, do : goin --update to install it."
fi