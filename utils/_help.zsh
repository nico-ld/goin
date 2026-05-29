#!/bin/zsh

_goin_help() {
	echo -e "  \033[1mUsage:\033[0m "
    echo -e "\tgoin [-ap] <[directory][path/to/dir]>"
    echo -e "\tgoin <option>"
    echo -e "\tgoin [-ap] <alias>"
	echo
	echo -e "  \033[1mDescription:\033[0m "
    echo -e "\tThis command allows you to access any directory from anywhere."
	echo
	echo -e "  \033[1mOptions:\033[0m"
	echo -e "\t-a         : Include hidden dir in research"
    echo -e "\t-b         : Work like '\033[3mcd -\033[0m' but without print the destination path"
	echo -e "\t-h --help  : Display informations about this command (For more information use --help)"
	echo -e "\t-p         : If the directory does not exist it is created"
	echo -e "\t--set-ls   : Set a flag in config file to execute '\033[3mls\033[0m' in your destination directory"
	echo -e "\t--unset-ls : Unset the ls flag in the config file"
	echo
	echo -e "  \033[1mAlias :\033[0m"
    echo -e "\tYou can customise this function with somes alias. This allows you to restrict the scope \n\tof the function on a given path. You can also use them to go faster in you're directory\n"
    echo -e "\t--set-alias <name> <path> : If the alias does not exist, it is created; otherwise, its path \n\t\tis modified. The name of you're alias have to start with '-' to be reconize like a flag"
    echo -e "\t--unset-alias <name> : Delete an alias"
	echo -e "\t--list-alias : List your aliases"
	echo
	echo -e "  \033[1mAuthor\033[0m : nico-ld."
}
