# includes others files
source "${0:A:h}/utils/_alias.zsh"
source "${0:A:h}/utils/_help.zsh"
source "${0:A:h}/utils/_update.zsh"

# 
# _update_config_file() -> modify .goin_config to always keep goin -l and goin -b working
# 
_update_config_file() {
    sed -i "s|^LAST_PATH=\".*\"|LAST_PATH=\"$1\"|" "$config_file"
    sed -i "s|^LAST_DIR=\".*\"|LAST_DIR=\"$2\"|" "$config_file"
}

#
# goin() -> main function. Parse all flags and call good function
#
goin() {
    local config_file="$HOME/.goin_config"

    if [[ ! -f "$config_file" ]]; then
        echo -e 'LAST_PATH="~"\nALIAS={}\nREPO="~/.goin_function"\nUPDATE_AVAI="false"\nLAST_FETCH="0"\n' > "$config_file"
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
			_update
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
