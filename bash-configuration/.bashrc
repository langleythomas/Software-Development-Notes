export PATH="$PATH:/opt/nvim/"

#######################################################################################################################
# Aliases
#######################################################################################################################

# File System

alias ll="ls -l"
alias rm="rm -i --verbose"

#######################################################################################################################
# Functions
#######################################################################################################################

# Script Execution

function execute_script() {
  local -r full_script_file_path="${1}"
  local -r script_file_path_without_directory_path="$(basename ${full_script_file_path})"
  local -r script_file_path_without_file_extension="${script_file_path_without_directory_path%.*}"

  time ./"${full_script_file_path=}" | tee "${script_file_path_without_file_extension}-$(date +%F-%T).txt"
}

#######################################################################################################################
# Update Packages
#######################################################################################################################

# System Upgrade

function update_all_packages() {
  local linux_distro_base="$(cat /proc/version)"

  if [[ "${linux_distro_base}" == *"arch"* ]]; then
    sudo pacman --sync --refresh --sysupgrade --noconfirm

    yay --sync --refresh --sysupgrade --noconfirm

    flatpak update
  elif [[ "${linux_distro_base}" == *"ubuntu"* ]]; then
    sudo apt update
    sudo apt upgrade --yes

    sudo snap refresh

    flatpak update
  fi
}
