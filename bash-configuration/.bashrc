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

    if [[ grep -q "endeavouros" "cat /etc/os-release" ]]; then
      eos-update --aur
    else
      sudo pacman --sync --refresh --sysupgrade

      yay --sync --refresh --sysupgrade
    fi

  elif [[ "${linux_distro_base}" == *"ubuntu"* ]]; then
    sudo apt update
    sudo apt upgrade

    sudo snap refresh
  fi

  flatpak update
}
