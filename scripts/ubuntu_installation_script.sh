#!/usr/bin/env bash

#######################################################################################################################
############################################## Generic Update Functions ###############################################
#######################################################################################################################
function update_and_upgrade_apt() {
  printf "Updating and updating releases in apt.\n"
  sudo apt update
  sudo apt upgrade --yes
}

function update_flatpak() {
  printf "Updating releases in Flatpak.\n"
  flatpak update
}

function update_snap() {
  printf "Updating releases in Snap.\n"
  sudo snap refresh
}

#######################################################################################################################
################################################ Script Output Functions ##############################################
#######################################################################################################################

function print_separator() {
  printf -- "-----------------------------------------------------------------------------------------------------------------------\n"
}

#######################################################################################################################
############################################### Nvidia-Specific Function ##############################################
#######################################################################################################################

function purge_nvidia_drivers() {
  # Run this command if there are issues booting into an Ubuntu installation. This failure could be caused by Nvidia driver issues. The commands below can resolve this issue. 
  # Note: These commands can only be effective after a clean OS installation.
  update_and_upgrade_apt

  printf "Purging Nvidia drivers.\n"

  sudo apt purge nvidia* --yes
  sudo ubuntu-drivers autoinstall

  print_separator
}

function call_nvidia_driver_function() {
  purge_nvidia_drivers
}

#######################################################################################################################
########################################### .NET Development Tool Functions ###########################################
#######################################################################################################################

function install_dot_net_sdk() {
  update_and_upgrade_apt

  printf "Installing .NET SDK.\n"

  sudo dpkg --purge packages-microsoft-prod && sudo dpkg --install packages-microsoft-prod.deb
  sudo apt-get install --yes dotnet-sdk-7.0
  dotnet --list-sdks
  dotnet --info

  print_separator
}

function install_dot_net_runtime() {
  update_and_upgrade_apt

  printf "Installing .NET Runtime.\n"

  sudo apt-get install --yes aspnetcore-runtime-7.0
  dotnet --list-runtimes
  dotnet --info

  print_separator
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

  printf "Installing JavaScript Development Tools.\n"
  sudo apt install --yes ca-certificates curl gnupg
  sudo mkdir --parents /etc/apt/keyrings
  curl --fail --silent --show-error --location "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" | sudo gpg --dearmor --output "/etc/apt/keyrings/nodesource.gpg"
  NODE_MAJOR=20
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

  sudo apt-get install nodejs --yes
}

function call_javascript_development_tool_functions() {
  install_javascript_development_tools
}

#######################################################################################################################
################################################ Deployment Tool Functions ############################################
#######################################################################################################################

function install_docker() {
  update_and_upgrade_apt

  printf "Installing Docker.\n"

  # Add Docker's official GPG key:
  sudo apt-get install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  # shellcheck disable=SC1091
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Install and Start Docker Engine.
  sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --yes

  # Add user to Docker group
  sudo usermod -aG docker "${USER}" && newgrp docker

  print_separator
}

function start_docker() {
  printf "Starting Docker.\n"

  sudo service docker start
  systemctl status docker.service

  print_separator
}

function test_docker_installation() {
  printf "Running a Test Docker Image.\n"

  sudo docker run hello-world

  print_separator
}

function install_minikube() {
  printf "Installing Minikube.\n"

  curl -Lo minikube "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
  chmod +x minikube
  sudo mv minikube /usr/local/bin/

  print_separator
}

function start_minikube() {
  printf "Starting Minikube.\n"

  minikube start

  print_separator
}

function install_kubernetes() {
  printf "Installing Kubernetes.\n"

  local -r latest_kubernetes_release="$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"

  curl -LO "https://storage.googleapis.com/kubernetes-release/release/${latest_kubernetes_release}/bin/linux/amd64/kubectl"
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl

  print_separator
}

function test_kubernetes_installation() {
  printf "Testing Kubernetes Installation.\n"

  kubectl version
  kubectl cluster-info

  print_separator
}

# Helm
function install_helm() {
  printf "Installing Helm.\n"

  curl "https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get-helm-3" > "get_helm.sh"
  chmod 700 "get_helm.sh"
  ./"get_helm.sh"

  print_separator
}

function test_helm_installation() {
  printf "Testing Helm Installation.\n"

  helm repo add bitnami "https://charts.bitnami.com/bitnami"
  helm install odoo bitnami/odoo --set serviceType=NodePort
  kubectl get pods | grep "Running"
  helm delete odoo

  print_separator
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

  printf "Installing vim.\n"
  sudo apt install vim --yes

  print_separator
}

function install_neovim() {
  update_flatpak

  printf "Installing Neovim.\n"

  printf "Downloading Neovim AppImage.\n"
  curl --location --remote-name "https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"
  chmod u+x nvim.appimage

  printf "Exposing nvim Globally.\n"
  sudo mkdir --parents "/opt/nvim"
  sudo mv nvim.appimage /opt/nvim/nvim

  print_separator
}

function install_visual_studio_code() {
  update_snap

  printf "Installing Visual Studio Code.\n"
  sudo snap install code

  # If there is an issue loading the Visual Studio Code GUI after an update, as described here https://code.visualstudio.com/Docs/supporting/FAQ#_vs-code-is-blank:
  # rm -r ~/.config/Code/GPUCache

  print_separator
}

function call_text_editor_installation_functions() {
  install_vim

  install_neovim

  install_visual_studio_code
}

#######################################################################################################################
############################################ Version Control Functions ################################################
#######################################################################################################################

function install_git() {
  update_and_upgrade_apt

  printf "Installing Git.\n"

  sudo apt install git --yes
  git --version

  print_separator
}

function configure_git_username_email() {
  printf "Setting up Git with a default username and email.\n"

  git config --global user.name "langleythomas"
  git config --global user.email "thomas.moorhead.langley@gmail.com"

  print_separator
}

function generate_github_ssh_key() {
  printf "Generating SSH key for cloning private GitHub repositories.\n"

  ssh-keygen -t ed25519 -C "thomas.moorhead.langley@gmail.com"
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519

  printf "Open the generated ssh key.\n"
  cat ~/.ssh/id_ed25519.pub
}

function call_version_control_functions() {
  install_git

  configure_git_username_email

  generate_github_ssh_key
}

#######################################################################################################################
######################################## Miscellaneous Tool Functions #################################################
#######################################################################################################################

function install_chrome() {
  update_flatpak

  printf "Installing Chrome.\n"

  flatpak install flathub com.google.Chrome --yes

  print_separator
}

function install_discord() {
  update_flatpak

  printf "Installing Discord.\n"

  flatpak install flathub com.discordapp.Discord --yes

  print_separator
}

function install_gnome_tweaks() {
  update_and_upgrade_apt

  printf "Installing GNOME Tweaks.\n"

  sudo apt install gnome-tweaks

  print_separator
}

function install_vlc() {
  update_and_upgrade_apt

  printf "Installing VLC.\n"

  flatpak install flathub org.videolan.VLC --yes

  print_separator
}

function configure_bashrc() {
  printf "Configuring .bashrc.\n"

  # TODO: Add the .bashrc steps.
  curl "https://raw.githubusercontent.com/langleythomas/Software-Development-Notes/main/bash-configurations/.bashrc" >> ~/."bashrc"
  source ~/."bashrc"

  print_separator
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

  printf "Autoremoving Unused Dependencies.\n"

  sudo apt autoremove --yes

  print_separator
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
