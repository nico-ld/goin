# goin
## Description
This is a small function to add to your '_.zshrc_'. It allows you to go to any directory from anywhere _(because `cd ../../directory` is too long)_.

## Install
Currently, this command is only avaible on **zsh** terminal.  
You can install it manually by cloning this repository and adding in your '_.zshrc_' file this line :
```bash
source ~/GIT_REPO/goin.zsh
```
Or simply run this command :
```bash
git clone https://github.com/nico-ld/goin.git ~/.goin_function && echo "source ~/.goin_function/goin.zsh" >> ~/.zshrc && source ~/.zshrc
```

## Usage
To use this function, you just need to specify which directory you want to go to. It can be a directory name, a relative path, or an absolute path (although using an absolute path is basically just a regular `cd`).

```bash
goin [flag] <directory_name>
goin [flag] <path/to/dir>
goin <option>
```

The difference between flags and options is that options must be used alone. Options are used to configure the function:

* `--help`: Display the man page.
* `--set-ls` / `--unset-ls`: Enable or disable a setting in the configuration file to run `ls` every time you use the function.
* `--update`: Get the latest version.
* `--version`: Print the current version.


> There is also alias configuration options : [here](#alias).

The flags are used to change the behavior of the function for the current execution (except for `-h` and `-b`):

* `-h`: Display the help menu.
* `-b`: Behave like `cd -`, but without printing the destination path.
* `-a`: Include hidden directories in the search.
* `-p`: If the directory does not exist, it is created. If a relative or absolute path is provided, the directory will be created there; otherwise, it will be created in the current working directory.

> If you provide a relative or absolute path containing hidden directories, the `-a` option will be automatically enabled.

## Alias
This function also allows you to create some aliases to go faster. You can set or modify them with:

```zsh
goin --set-alias <name> <path>
```
Your alias must start like a real flag (with '-'), otherwhise it will not be reconized.

To delete it, use :
```zsh
goin --unset-alias <name>
```
Then, to use them, execute the command in the normal way, but only type:

```zsh
goin <alias>
```
You can also list your aliases with :
```zsh
goin --list-alias
```