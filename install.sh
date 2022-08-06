#!/usr/bin/env bash

source_directory=$(readlink -f "$(dirname "$0")")
if [ "$PWD" != "$source_directory" ]; then
  pushd "$source_directory" || exit
fi

source functions.bash

clone_machine_specific_dotfiles

generate_untracked_gitconfig

create_project_symlink

manage_dotfile_symlinks

manage_submodules
