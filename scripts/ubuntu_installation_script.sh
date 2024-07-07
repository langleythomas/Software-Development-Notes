#!/usr/bin/env bash

#######################################################################################################################
################################################ Script Output Function ###############################################
#######################################################################################################################

function log_output() {
  local -r logger_output="${1}"

  printf "%s" "${logger_output}"
  printf -- "-----------------------------------------------------------------------------------------------------------------------\n"
}

#######################################################################################################################
############################################## Generic Update Functions ###############################################
#######################################################################################################################
function update_and_upgrade_apt() {
  log_output "Updating and updating releases in apt.\n"

  sudo apt update
  sudo apt upgrade --yes
}

function update_flatpak() {
  log_output "Updating releases in Flatpak.\n"

  flatpak update
}

function update_snap() {
  log_output "Updating releases in Snap.\n"

  sudo snap refresh
}

#######################################################################################################################
############################################### Nvidia-Specific Function ##############################################
#######################################################################################################################

function purge_nvidia_drivers() {
  # Run this command if there are issues booting into an Ubuntu installation. This failure could be caused by Nvidia
  # driver issues. The commands in this function can resolve this issue. These commands can only be effective in a
  # fresh OS installation.

  update_and_upgrade_apt

  log_output "Purging Nvidia drivers.\n"

  sudo apt purge nvidia* --yes
  sudo ubuntu-drivers autoinstall
}

function call_nvidia_driver_function() {
  purge_nvidia_drivers
}

#######################################################################################################################
########################################### .NET Development Tool Functions ###########################################
#######################################################################################################################

function install_dot_net_sdk() {
  update_and_upgrade_apt

  log_output "Installing .NET SDK.\n"

  sudo dpkg --purge packages-microsoft-prod && sudo dpkg --install packages-microsoft-prod.deb
  sudo apt install --yes dotnet-sdk-7.0

  dotnet --list-sdks
  dotnet --info
}

function install_dot_net_runtime() {
  update_and_upgrade_apt

  log_output "Installing .NET Runtime.\n"

  sudo apt install --yes aspnetcore-runtime-7.0

  dotnet --list-runtimes
  dotnet --info
}

function call_dot_net_development_tool_functions() {
  install_dot_net_sdk
  install_dot_net_runtime
}

#######################################################################################################################
######################################## JavaScript Development Tool Functions ########################################
#######################################################################################################################

function install_javascript_development_tools() {
  update_and_upgrade_apt

  log_output "Installing JavaScript Development Tools.\n"

  sudo apt install --yes ca-certificates curl gnupg
  sudo mkdir --parents /etc/apt/keyrings

  curl \
    --fail \
    --silent \
    --show-error \
    --location "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" \
    | sudo gpg --dearmor --output "/etc/apt/keyrings/nodesource.gpg"

  local -r node_version=20

  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$node_version.x nodistro main" \
    | sudo tee /etc/apt/sources.list.d/nodesource.list

  sudo apt install nodejs --yes
}

function call_javascript_development_tool_functions() {
  install_javascript_development_tools
}

#######################################################################################################################
################################################ Deployment Tool Functions ############################################
#######################################################################################################################

function install_docker() {
  update_and_upgrade_apt

  log_output "Installing Docker.\n"

  # Add Docker's official GPG key:
  sudo apt install ca-certificates curl

  sudo install --mode=0755 --directory="/etc/apt/keyrings"

  sudo curl \
    --fail \
    --silent \
    --show-error \
    --location "https://download.docker.com/linux/ubuntu/gpg" \
    --output "/etc/apt/keyrings/docker.asc"

  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  # shellcheck disable=SC1091
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Install and Start Docker Engine.
  sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --yes

  # Add user to Docker group
  sudo usermod --append --groups docker "${USER}" && newgrp docker
}

function start_docker() {
  log_output "Starting Docker.\n"

  sudo service docker start

  systemctl status docker.service
}

function test_docker_installation() {
  log_output "Running a Test Docker Image.\n"

  sudo docker run hello-world
}

function install_minikube() {
  log_output "Installing Minikube.\n"

  curl \
    --location \
    --output "minikube" \
    "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"

  chmod +x "minikube"

  sudo mv "minikube" "/usr/local/bin/"
}

function start_minikube() {
  log_output "Starting Minikube.\n"

  minikube start
}

function install_kubernetes() {
  log_output "Installing Kubernetes.\n"

  local -r latest_kubernetes_release="$(curl --silent https://storage.googleapis.com/kubernetes-release/release/stable.txt)"

  curl \
    --location \
    --output \
    "https://storage.googleapis.com/kubernetes-release/release/${latest_kubernetes_release}/bin/linux/amd64/kubectl"

  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
}

function test_kubernetes_installation() {
  log_output "Testing Kubernetes Installation.\n"

  kubectl version
  kubectl cluster-info
}

# Helm
function install_helm() {
  log_output "Installing Helm.\n"

  local -r install_helm_file_name="get_helm.sh"
  curl "https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get-helm-3" > "${install_helm_file_name}"
  chmod 700 "${install_helm_file_name}"
  ./"${install_helm_file_name}"
  rm --force --verbose "${install_helm_file_name}"
}

function test_helm_installation() {
  log_output "Testing Helm Installation.\n"

  helm repo add bitnami "https://charts.bitnami.com/bitnami"
  helm install odoo bitnami/odoo --set serviceType=NodePort
  kubectl get pods | grep "Running"
  helm delete odoo
}

function call_deployment_tool_functions() {
  install_docker
  start_docker
  test_docker_installation

  install_minikube
  start_minikube

  install_kubernetes
  test_kubernetes_installation

  install_helm
  test_helm_installation
}

#######################################################################################################################
########################################### Text Editors Functions ####################################################
#######################################################################################################################

function install_vim() {
  update_and_upgrade_apt

  log_output "Installing vim.\n"
  log_output "\tNote: vim-gtk3 is being installed, as that supports copying and pasting to and from the system clipboard\n."
  log_output "\tvim-gnome is not being installed, as that is not in the repositories of the latest Ubuntu releases.\n"
  sudo apt-get install vim-gtk3 --yes
}

function install_vundle() {
  log_output "Installing Vundle, the Vim package manager, as documented in: https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file#installation--usage\n"

  git clone "https://github.com/VundleVim/Vundle.vim.git" ~/".vim/bundle/Vundle.vim"
}

function configure_vim() {
  log_output "Creating Vim configuration directories and configuration file.\n"

  mkdir --verbose --parents ~/".vim" ~/".vim/autoload" ~/".vim/backup" ~/".vim/colors" ~/".vim/plugged"
  touch ~/".vimrc"
  curl \
    "https://raw.githubusercontent.com/langleythomas/software-development-notes/main/vim-configuration/.vimrc" \
    >> ~/".vimrc"

  # There is no need for a source command on the .vimrc, as the .vimrc is automatically read and validated when
  # executing the vim command in a terminal.
}

function install_vundle_plugins() {
  log_output "Installing Vim plugins using Vundle, as documented in: https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file#installation--usage\n"

  vim ~/".vimrc" --cmd "source %" +qall
  vim +PluginInstall +qall
  vim ~/".vimrc" -c "call mkdp#util#install()" +qall
}

function install_visual_studio_code() {
  update_and_upgrade_apt

  log_output "Installing Visual Studio Code.\n"

  sudo apt install wget gpg --yes
  wget --quiet -output-document=- "https://packages.microsoft.com/keys/microsoft.asc" \
    | gpg --dearmor > "packages.microsoft.gpg"
  sudo install -D --owner=root --group=root --mode=644 "packages.microsoft.gpg" "/etc/apt/keyrings/packages.microsoft.gpg"
  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
  rm --force --verbose "packages.microsoft.gpg"

  update_and_upgrade_apt
  sudo apt install apt-transport-https --ye

  update_and_upgrade_apt
  sudo apt install code --yes

  # Execute the following command there is an issue loading the Visual Studio Code GUI after an update, as described
  # here: https://code.visualstudio.com/Docs/supporting/FAQ#_vs-code-is-blank:
  # rm -r ~/.config/Code/GPUCache
}

function call_text_editor_installation_functions() {
  install_vim
  install_vundle
  configure_vim
  install_vundle_plugins

  install_visual_studio_code
}

#######################################################################################################################
############################################ Version Control Functions ################################################
#######################################################################################################################

function install_git() {
  update_and_upgrade_apt

  log_output "Installing Git.\n"

  sudo apt install git --yes
  git --version
}

function configure_git_username_email() {
  log_output "Setting up Git with a default username and email.\n"

  git config --global user.name "langleythomas"
  git config --global user.email "thomas.moorhead.langley@gmail.com"
}

function generate_github_ssh_key() {
  log_output "Generating SSH key for cloning private GitHub repositories.\n"

  ssh-keygen -t ed25519 -C "thomas.moorhead.langley@gmail.com"
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519

  log_output "Opening the generated ssh key.\n"

  cat ~/.ssh/id_ed25519.pub
}

function call_version_control_functions() {
  install_git

  configure_git_username_email
  generate_github_ssh_key
}

#######################################################################################################################
####################################### Configure Linux System Overrides ##############################################
#######################################################################################################################

function configure_bashrc() {
  log_output "Configuring .bashrc.\n"

  curl \
    "https://raw.githubusercontent.com/langleythomas/Software-Development-Notes/main/bash-configuration/.bashrc" \
    >> ~/."bashrc"

  # shellcheck disable=SC1090
  source ~/".bashrc"
}

function call_linux_system_overrides_function() {
  configure_bashrc
}

#######################################################################################################################
######################################## Miscellaneous Tool Functions #################################################
#######################################################################################################################

function install_chrome() {
  update_flatpak

  log_output "Installing Chrome.\n"

  flatpak install flathub com.google.Chrome --yes
}

function install_discord() {
  update_flatpak

  log_output "Installing Discord.\n"

  flatpak install flathub com.discordapp.Discord --yes
}

function install_gnome_tweaks() {
  update_and_upgrade_apt

  log_output "Installing GNOME Tweaks.\n"

  sudo apt install gnome-tweaks
}

function install_vlc() {
  update_and_upgrade_apt

  log_output "Installing VLC.\n"

  flatpak install flathub org.videolan.VLC --yes
}

function call_miscellaneous_tool_functions() {
  install_chrome

  install_discord

  install_gnome_tweaks

  install_vlc
}

#######################################################################################################################
######################################## Autoremove Dependency Function ###############################################
#######################################################################################################################

function autoremove_unused_dependencies() {
  update_and_upgrade_apt

  log_output "Autoremoving Unused Dependencies.\n"

  sudo apt autoremove --yes
}

function call_autoremove_unused_dependency_function() {
  autoremove_unused_dependencies
}

#######################################################################################################################
########################################## Common Function Callers ####################################################
#######################################################################################################################

# call_nvidia_driver_function

# call_dot_net_development_tool_functions

# call_javascript_development_tool_functions

# call_deployment_tool_functions

# call_text_editor_installation_functions

# call_version_control_functions

# call_miscellaneous_tool_functions

# call_autoremove_unused_dependency_function
