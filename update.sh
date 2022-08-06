#!/usr/bin/env bash

source_directory=$(readlink -f "$(dirname "$0")")
if [ "$PWD" != "$source_directory" ]; then
  pushd "$source_directory" || exit
fi

source functions.bash

git pull

manage_dotfile_symlinks

manage_submodules
