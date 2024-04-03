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
  printf "Updating releases in flatpak.\n"
  flatpak update
}

function update_snap() {
  printf "Updating releases in snap.\n"
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
  printf "Installing .NET SDK.\n"

  update_and_upgrade_apt

  sudo dpkg --purge packages-microsoft-prod && sudo dpkg --install packages-microsoft-prod.deb

  sudo apt-get install --yes dotnet-sdk-7.0

  dotnet --list-sdks
  dotnet --info

  print_separator
}

function install_dot_net_runtime() {
  printf "Installing .NET Runtime.\n"

  update_and_upgrade_apt

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
  printf "Installing JavaScript Development Tools.\n"

  update_and_upgrade_apt

  sudo apt install --yes ca-certificates curl gnupg
  sudo mkdir --parents /etc/apt/keyrings

  curl --fail --silent --show-error --location "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" | sudo gpg --dearmor --output "/etc/apt/keyrings/nodesource.gpg"
  NODE_MAJOR=20

  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

  update_and_upgrade_apt

  sudo apt-get install nodejs --yes
}

function call_javascript_development_tool_functions() {
  install_javascript_development_tools
}

#######################################################################################################################
################################################ Deployment Tool Functions ############################################
#######################################################################################################################

function install_docker() {
  printf "Installing Docker.\n"

  # Add Docker's official GPG key:
  update_and_upgrade_apt
  sudo apt-get install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  update_and_upgrade_apt

  # Install and Start Docker Engine.
  sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --yes

  # Add use to Docker group
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
  update_flatpak

  sudo apt install vim --yes

  print_separator
}

function install_visual_studio_code() {
  update_flatpak

  printf "Installing Visual Studio Code.\n"

  flatpak install flathub com.visualstudio.code --yes

  # If there is an issue loading the Visual Studio Code GUI after an update, as described here https://code.visualstudio.com/Docs/supporting/FAQ#_vs-code-is-blank: rm -r ~/.config/Code/GPUCache

  print_separator
}

function call_text_editor_installation_functions() {
  install_visual_studio_code
}

#######################################################################################################################
#################################################### Font Functions ###################################################
#######################################################################################################################

function install_san_fransisco_pro_fonts_common() {
  local font_type="${1}"

  printf "Installing the San Francisco %s fonts.\n" "${font_type}"

  local -r script_directory="$(pwd)"

  curl "https://devimages-cdn.apple.com/design/resources/download/SF-${font_type}.dmg" --output "SF-${font_type}.dmg"

  7z x "SF-${font_type}.dmg"

  cd "SF${font_type}Fonts" || exit

  7z x "SF ${font_type} Fonts.pkg"
  7z x "Payload~"

  cd "Library" || exit
  cd "Fonts" || exit

  sudo mv -- * ~/.fonts

  cd "${script_directory}" || exit

  print_separator
}

function install_san_francisco_pro_fonts() {
  install_san_fransisco_pro_fonts_common "Pro"
}

function install_san_francisco_mono_fonts() {
  install_san_fransisco_pro_fonts_common "Mono"
}

function call_font_functions() {
  install_san_francisco_pro_fonts
  install_san_francisco_mono_fonts
}

#######################################################################################################################
############################################ Version Control Functions ################################################
#######################################################################################################################

function install_git() {
  printf "Installing Git.\n"

  update_and_upgrade_apt

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

function install_brave() {
  printf "Installing Brave.\n"

  update_flatpak

  flatpak install flathub com.brave.Browser --yes

  print_separator
}

function install_discord() {
  printf "Installing Discord.\n"

  update_flatpak

  flatpak install flathub com.discordapp.Discord --yes

  print_separator
}

function install_vlc() {
  printf "Installing VLC.\n"

  update_and_upgrade_apt

  flatpak install flathub org.videolan.VLC --yes

  print_separator
}

function call_miscellaneous_tool_functions() {
  install_brave

  install_discord

  install_vlc
}

#######################################################################################################################
######################################## Autoremove Dependency Function ###############################################
#######################################################################################################################

function autoremove_unused_dependencies() {
  printf "Autoremoving unused dependencies.\n"

  update_and_upgrade_apt

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

# call_font_functions

# call_version_control_functions

# call_miscellaneous_tool_functions

# call_autoremove_unused_dependency_function
