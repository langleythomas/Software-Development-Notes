#!/usr/bin/env bash

#######################################################################################################################
################################################ Script Output Function ###############################################
#######################################################################################################################

function print_separator() {
    printf -- "-----------------------------------------------------------------------------------------------------------------------\n"
}

function log_output() {
    local -r logger_output="${1}"

    print_separator
    printf "%s" "${logger_output}"
    print_separator
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
    sudo ubuntu-drivers autoinstall --yes
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
    sudo mkdir --parents "/etc/apt/keyrings"

    curl \
        --fail \
        --silent \
        --show-error \
        --location "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" |
        sudo gpg --dearmor --output "/etc/apt/keyrings/nodesource.gpg"

    local -r node_version=20

    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] \
        https://deb.nodesource.com/node_$node_version.x nodistro main" |
        sudo tee /etc/apt/sources.list.d/nodesource.list

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

    sudo install \
        --mode=0755 \
        --directory="/etc/apt/keyrings"

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
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
        https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install and Start Docker Engine.
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --yes

    # Add user to Docker group
    sudo usermod --append --groups "docker" "${USER}" && newgrp "docker"
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

    local -r latest_kubernetes_release="$(curl --silent \"https://storage.googleapis.com/kubernetes-release/release/stable.txt\")"

    curl \
        --location \
        --output \
        "https://storage.googleapis.com/kubernetes-release/release/${latest_kubernetes_release}/bin/linux/amd64/kubectl"

    chmod +x ./"kubectl"

    sudo mv ./"kubectl" "/usr/local/bin/kubectl"
}

function test_kubernetes_installation() {
    log_output "Testing Kubernetes Installation.\n"

    kubectl version
    kubectl cluster-info
}

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

    git clone "https://github.com/VundleVim/Vundle.vim.git" "${dot_vim_directory_path}/bundle/Vundle.vim"
}

function configure_vim() {
    local -r vimrc_file_path="${1}"
    local -r dot_vim_directory_path="${2}"

    log_output "Creating Vim configuration directories and configuration file.\n"

    mkdir \
        --verbose \
        --parents \
        "${dot_vim_directory_path}" \
        "${dot_vim_directory_path}/autoload" \
        "${dot_vim_directory_path}/backup" \
        "${dot_vim_directory_path}/colors" \
        "${dot_vim_directory_path}/plugged"

    curl \
        "https://raw.githubusercontent.com/langleythomas/software-development-notes/main/vim-configuration/.vimrc" \
        >> "${vimrc_file_path}"

    # There is no need for a source command on the .vimrc, as the .vimrc is automatically read and validated when
    # executing the vim command in a terminal.
}

function install_vim_dracula_theme() {
    log_output "Installing the Dracula Vim theme, as documented in: https://draculatheme.com/vim\n"

    vim +PluginInstall +qall
}

function install_vim_markdown_preview() {
    log_output "Installing Vim plugins using Vundle, as documented in: https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file#installation--usage\n"

    vim "${vimrc_file_path}" --cmd "source %" +qall
    vim +PluginInstall +qall
    vim "${vimrc_file_path}" -c "call mkdp#util#install()" +qall
}

function install_neovim() {
    log_output "Installing Neovim.\n"

    log_output "Downloading Neovim AppImage.\n"

    curl --location --remote-name "https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"
    chmod u+x "nvim.appimage"

    log_output "Moving Neovim Making it Globally Accessible.\n"

    sudo mkdir --parents "/opt/nvim"
    sudo mv "nvim.appimage" "/opt/nvim/nvim"
}

function configure_neovim() {
    local -r dot_config_neovim_directory_path="${HOME}/.config/nvim"

    log_output "Creating Neovim configuration directories and configuration files.\n"

    mkdir  \
        --verbose \
        --parents \
        "${dot_config_neovim_directory_path}"

    curl \
        "https://raw.githubusercontent.com/langleythomas/software-development-notes/main/neovim-configuration/init.vim" \
        >> "${dot_config_neovim_directory_path}/init.vim"

    # There is no need for a source command on the init.vim, as the init.vim is automatically read and validated when
    # executing the vim command in a terminal.
}

function install_neovim_system_clipboard_dependency() {
    update_and_upgrade_apt

    log_output "Installing xclip, in order to enable neovim's use of the system clipboard.\n"

    sudo apt install xclip --yes
}

function install_visual_studio_code() {
    update_and_upgrade_apt

    log_output "Installing Visual Studio Code.\n"

    sudo apt install wget gpg --yes

    wget --quiet -output-document=- "https://packages.microsoft.com/keys/microsoft.asc" \
        | gpg --dearmor > "packages.microsoft.gpg"

    sudo install -D \
        --owner=root \
        --group=root \
        --mode=644 \
        "packages.microsoft.gpg" \
        "/etc/apt/keyrings/packages.microsoft.gpg"

    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] \
        https://packages.microsoft.com/repos/code stable main" |
        sudo tee /etc/apt/sources.list.d/vscode.list > "/dev/null"

    rm \
        --force \
        --verbose \
        "packages.microsoft.gpg"

    update_and_upgrade_apt
    sudo apt install apt-transport-https --yes

    update_and_upgrade_apt
    sudo apt install code --yes

    # Execute the following command there is an issue loading the Visual Studio Code GUI after an update, as described
    # here: https://code.visualstudio.com/Docs/supporting/FAQ#_vs-code-is-blank:
    # rm -r ~/.config/Code/GPUCache
}

function install_sublime_text() {
    update_and_upgrade_apt

    log_output "Installing Sublime Text.\n"

    wget --quiet --output-document="-" "https://download.sublimetext.com/sublimehq-pub.gpg" \
        | gpg --dearmor \
        | sudo tee "/etc/apt/trusted.gpg.d/sublimehq-archive.gpg" > "/dev/null"

    echo "deb https://download.sublimetext.com/ apt/stable/" \
        | sudo tee "/etc/apt/sources.list.d/sublime-text.list"

    sudo apt install sublime-text
}

function install_intellij() {
    update_snap

    log_output "Installing IntelliJ IDEA Community Edition"

    sudo snap install intellij-idea-community --classic
}

function install_pycharm() {
    update_snap

    log_output "Installing PyCharm Community Edition."

    sudo snap install pycharm-community --classic
}

function call_text_editor_installation_functions() {
    local -r vimrc_file_path="${HOME}/.bashrc"
    local -r dot_vim_directory_path="${HOME}/.vim"
    install_vim "${vimrc_file_path}" "${dot_vim_directory_path}"
    configure_vim "${vimrc_file_path}" "${dot_vim_directory_path}"
    install_vim_dracula_theme
    install_vim_markdown_preview "${vimrc_file_path}"

    install_neovim
    configure_neovim
    install_neovim_system_clipboard_dependency

    install_visual_studio_code

    install_sublime_text

    install_intellij
    install_pycharm
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

function configure_git_global_parameters() {
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

    configure_git_global_parameters

    generate_github_ssh_key
}



#######################################################################################################################
####################################### Configure Linux System Overrides ##############################################
#######################################################################################################################

function configure_bashrc() {
    log_output "Configuring .bashrc.\n"

    curl \
        "https://raw.githubusercontent.com/langleythomas/Software-Development-Notes/main/bash-configuration/.bashrc" \
        >> "${HOME}/.bashrc"

    # shellcheck disable=SC1090
    # shellcheck disable=SC1091
    source "${HOME}/.bashrc"
}

function call_linux_system_overrides_function() {
    configure_bashrc
}



#######################################################################################################################
############################################## Browser Function #######################################################
#######################################################################################################################

function install_chrome() {
    update_flatpak

    log_output "Installing Chrome.\n"

    flatpak install flathub com.google.Chrome --yes
}

function call_browser_installation_function() {
    install_chrome
}



#######################################################################################################################
############################################ Social Platform Function #################################################
#######################################################################################################################

function install_discord() {
    update_flatpak

    log_output "Installing Discord.\n"

    flatpak install flathub com.discordapp.Discord --yes
}

function call_social_platform_function() {
    install_discord
}



#######################################################################################################################
########################################## UI Configuration Function ##################################################
#######################################################################################################################

function install_gnome_tweaks() {
    update_and_upgrade_apt

    log_output "Installing GNOME Tweaks.\n"

    sudo apt install gnome-tweaks
}

function call_ui_configuration_installation_function() {
    install_gnome_tweaks
}



#######################################################################################################################
############################################ Media Player Function ####################################################
#######################################################################################################################

function install_vlc() {
    update_flatpak

    log_output "Installing VLC.\n"

    flatpak install flathub org.videolan.VLC --yes
}

function call_media_player_installation_function() {
    install_vlc
}



#######################################################################################################################
############################################## Terminal Functions #####################################################
#######################################################################################################################

function install_guake() {
    update_and_upgrade_apt

    log_output "Installing Guake. Note: In order to launch Guake, hit the F12 key.\n"

    sudo apt install guake --yes
}

function configure_guake() {
    log_output "Configuring Guake.\n"

    curl \
        "https://raw.githubusercontent.com/langleythomas/Software-Development-Notes/main/guake-configuration/guake_configuration.conf" \
        >> "${HOME}/Downloads/guake_configuration.conf"

    guake --restore-preferences="${HOME}/Downloads/guake_configuration.conf"
}

function call_terminal_installation_functions() {
    install_guake

    configure_guake
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

# call_browser_installation_function

# call_social_platform_function

# call_ui_configuration_installation_function

# call_media_player_installation_function

# call_terminal_installation_functions

# call_autoremove_unused_dependency_function
