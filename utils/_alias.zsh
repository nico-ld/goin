#!/bin/zsh

# 
# _list_alias() -> list alias from config dir
# 
_list_alias() {
    # Extract the ALIAS line
    local alias_line
    alias_line=$(grep '^ALIAS=' "$config_file" | head -1)

    if [[ -z "$alias_line" ]]; then
        echo "goin: $INFO: You have no alias."
        return 0
    fi

    # Strip ALIAS={ ... }
    local inner="${alias_line#ALIAS=\{}"
    inner="${inner%\}}"

    # Split on ',' and print each key:value pair
    echo "$inner" | tr ',' '\n' | while IFS=':' read -r key val; do
        # Strip surrounding quotes
        key="${key//\"/}"
        val="${val//\"/}"
        printf "%-10s %s\n" "$key" "$val"
    done
}

_is_a_flag() {
    case "$1" in
        -h|-b|-p)
            echo -e "goin: $ERROR: '$1' is an existing option"
            return 1
            ;;
    esac
    return 0
}

# 
# _alias_management() -> add/remove/rename/list alias
# 
_alias_management() {
    if [[ "$1" == "update" ]]; then
        # testing alias name
		if [[ ! "${3:0:1}" == "-" ]]; then
			echo -e "goin: $ERROR: '$3': Alias must start with '-'"
			return 10
        elif grep -q -- "$3" ~/.goin_config; then
            echo -e "goin: $ERROR: '$3': This alias already exist"
            return 11
		fi
		_is_a_flag "$3"
		if [ $? -eq 1 ]; then
			return 12
        fi
    
        # testing alias
        if [[ ! -d "$4" ]]; then
            echo -e "goin: $ERROR: No such directory named '$4'"
            return 127
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
            echo -e "goin: $ERROR: No such alias named '$3'"
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
            echo -e "goin: $ERROR: Unkwnow flag or alias"
            return 12
        fi
        
        local target=$(grep '^ALIAS=' "$config_file" | cut -d '=' -f2- | grep -o "\"$2\":\"[^\"]*\"" | cut -d ':' -f2 | tr -d '"')
        
        local current_dir=${PWD}
		if [[ -z "$4" ]]; then
	        cd "$target"
    	    _update_config_file "$target" "$current_dir"
		else
			_research "$target" "$current_dir" "$4"
		fi
	fi
}
