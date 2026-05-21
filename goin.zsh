#!/bin/zsh

# includes others files
source "${0:A:h}/utils/_alias.zsh"
source "${0:A:h}/utils/_help.zsh"
source "${0:A:h}/utils/_research.zsh"
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
    local arg
	local flag
	local count

	for arg in "$@"; do 
		(( count++ ))
		case "$arg" in
			--*)
				if [[ ! count -eq 1 ]]; then
					echo "goin: ${arg#} have to be used alone"
					return 1
				fi
				case "$arg" in
					--help) _goin_help ;;
					--back) 
						cd "$back"
						echo "going back option" 
						;;
					--set-alias) echo "set/modify option" ;;
					--unset-alias) echo "remove alias option" ;;
					--update) echo "update option" ;;
					--*) echo "Unknow option" ;;
				esac
				return "$?"
				;;
			-*)
				# Short option(s): strip the leading '-', then iterate chars
				local opts="${arg#-}"
				local i=1
				if (grep "ALIAS" "$HOME/.goin_config" | grep -q -- "\"$arg\":"); then
					_alias_management "research" "$arg"
					return 0
				fi
				while [[ $i -le ${#opts} ]]; do
					flag="${opts[$i]}"
					case "$flag" in
						h) 
							_goin_help
							return 0
							;;
						l) 
							echo "Flag: ls"
							;;
						b) 
							cd "back"
							_update_config_file "$back" "$current_dir"
							return 0
							;;
						*) 
							echo "Unknown flag or alias: -$flag"
							;;
					esac
					(( i++ ))
				done
				;;
			*)
				_research "~" "$current_dir" "$1"
				;;
			esac
	done

    local return_code="$?"

    return "$return_code"
}
