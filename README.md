# Software-Development-Notes

- [Software-Development-Notes](#software-development-notes)
  - [Repository Overview](#repository-overview)
  - [Repository Directory Structure](#repository-directory-structure)
    - [`bash-configuration`](#bash-configuration)
    - [`guake-configuration`](#guake-configuration)
    - [`neovim-configuration`](#neovim-configuration)
    - [`notes`](#notes)
    - [`scripts`](#scripts)
    - [`sublime-text-configuration`](#sublime-text-configuration)
    - [`vim-configuration`](#vim-configuration)
    - [`visual-studio-configuration`](#visual-studio-configuration)

## Repository Overview

This repository contains the notes and cheat sheets that have been compiled in the aims of learning new skills, tools,
and techniques related to software development. It also contains files to configure text editors that have been
identified and chosen for use. There is a Bash script written to configure and install software after a fresh
installation of a Linux distribution.

## Repository Directory Structure

The following is the outline of the directories in this repository:

### `bash-configuration`

Contains the `.bashrc` file containing overrides and aliases to ensure the consistency of commands and functionality in
the interactive shell sessions across Linux distributions.

### `guake-configuration`

Contains the `guake_configuration.conf` file containing the overrides required to configure the Guake text editor.

### `neovim-configuration`

Contains the `init.vim` file containing the overrides required to configure the Neovim text editor.

### `notes`

Contains the `Upskilling-Notes.md` file containing summaries and listing resource locations used to learn more about
different tools, technologies, and techniques related to software development.

### `scripts`

Contains the `linux_configuration_script.sh` script file required to install software across Debian, Arch, OpenSUSE,
and Fedora systems and set overrides. Note that in order to ensure each function in the script executes without any
issue, you will need to edit the script by removing each comment in the function callers at the bottom of each file.
Run each of the scripts in this directory by executing the following commands:

```bash
export SCRIPT_FILE_PATH="<Path to the script you wish to run>"
chmod +x "${SCRIPT_FILE_PATH}"
./"${SCRIPT_FILE_PATH}"
```

### `sublime-text-configuration`

Contains the `Preferences.sublime-settings` file containing the overrides required to configure the Sublime Text
Editor.

### `vim-configuration`

Contains the `.vimrc` file containing the overrides required to configure the Vim text editor.

### `visual-studio-configuration`

Contains JSON files containing the overrides required to configure the Visual Studio Code text editor.
