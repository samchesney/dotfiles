#!/usr/bin/env bash

source_directory=$(readlink -f "$(dirname "$0")")
if [ "$PWD" != "$source_directory" ]; then
  pushd "$source_directory" || exit
fi

# Git user credentials are not checked in
if [ ! -f "$HOME"/.gitconfig_untracked ]; then
  echo "Enter full name for Git global config:"
  read -r git_user_name
  echo "Enter email address for Git global config:"
  read -r git_user_email
  echo -e -n \
"[user]\n\
\tname = $git_user_name\n\
\temail = $git_user_email\n\
#\tsigningkey = \n\
#[commit]\n\
#\tgpgSign = true\n" \
>> "$HOME"/.gitconfig_untracked
else
  echo -e "$HOME/.gitconfig_untracked already exists:\n\
  Ensure at least full name and  email are set."
fi

# Ensure this dotfile repo is installed in a known location
install_link=$HOME/.dotfiles
echo -e "\nCreating symlink for $PWD directory"
if [ -L "$install_link" ]; then
  # Delete any existing symlink to avoid the risk of following it when
  # updating to the current location.
  rm "$install_link"
fi
ln -si "$PWD"/ "$install_link"

# Build list of files managed by this dotfiles repo
dir_list=(symlinked_files*/)
file_list=()
for dir in "${dir_list[@]}"; do
  file_list+=("$dir"*)
done
echo "${#file_list[@]} files to symlink found"

# Create backup directory for any existing versions of dotfiles
backup_dir=$HOME/dotfiles_backup-$(date +%s)
backup_dir_created=false
backup_count=0
echo "Creating backup directory $backup_dir"
if mkdir "$backup_dir"; then
  backup_dir_created=true
fi

# Install the managed files
for file in "${file_list[@]}"; do

  # Check for any exitisting versions of these files
  filename=.$(basename "$file")
  echo -e "\nChecking for existing version of $filename"
  if find -f "$HOME"/"$filename" > /dev/null 2>&1; then
    echo "  Found existing vesion... moving to $backup_dir"
    mv "$HOME"/"$filename" "$backup_dir"
    backup_count=$((backup_count+1))
  else
    echo "  No existing version found"
  fi

  # Create symlink to the managed version
  echo "Creating symlink for $file"
  ln -s "$PWD"/"$file" "$HOME"/"$filename"

done

# Remove backup directory if there was nothing to backup
if [ $backup_count -eq 0 ] && [ $backup_dir_created == true ]; then
  echo -e "\nRemoving unused backup directory $backup_dir"
  rm -r "$backup_dir"
fi

# Ensure git submodules have been cloned
git submodule init
git submodule update --depth 1
